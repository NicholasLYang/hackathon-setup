echo "Please enter your project name. Project names should be unique and skeleton-case"
read projectName
echo "Creating $projectName"
projectNameClient="$projectName"-client
aws s3api create-bucket --bucket $projectNameClient --region us-east-1
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

