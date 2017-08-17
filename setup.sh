main() {
    echo "Please enter your project name. Project names should be unique and skeleton-case"
    read projectName
    projectNameClient="$projectName"-client
    projectNameApi="$projectName"-api
    echo "Creating bucket: $projectNameClient"
    if aws s3api create-bucket --bucket $projectNameClient --region us-east-1; then
        echo "Bucket created"
    else
        echo "Failed to create bucket, exiting"
        exit
    fi
    mkdir $projectName
    cd $projectName
    mkdir $projectNameClient
    cd $projectNameClient
    yo react-redux-gulp
    gulp build
    aws s3 sync dist/prod s3://"$projectNameClient"
    cat > policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$projectNameClient/*"
        }
    ]
}

EOF

    aws s3api put-bucket-policy --bucket $projectNameClient --policy file://policy.json
    aws s3 website s3://$projectNameClient --index-document index.html --error-document index.html
    cd ..

    rails new $projectNameApi --api --skip-yarn
    cd $projectNameApi
    echo "gem 'rack-cors'" >> Gemfile
    echo "gem 'olive_branch'" >> Gemfile
    bundle install
    cd config
    cat > application.rb <<EOF
require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [
                   :get,
                   :post,
                   :put,
                   :delete,
                   :options
                 ]
      end
    end
    config.middleware.use OliveBranch::Middleware
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end

EOF
    cd ../app/controllers
    rm application_controller.rb
    cat > application_controller.rb <<EOF
class ApplicationController < ActionController::API
  before_action :cors_preflight_check

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] =
        'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
end

EOF
    echo "** NOTE: CORS is configured to be highly insecure **"
    echo "** You are at an EXTREMELY HIGH risk of XSS attacks **"
    cd ../..
    git init
    git add .
    git commit -m 'Initial commit'
    echo "** Remember to create repo! **"
    eb init
    eb create
    secretKey="$(rake secret)"
    eb setenv SECRET_KEY_BASE="${secretKey}"
}

main

