# hackathon-setup
A script for setting up my hackathon stack (Rails API + React/Redux app)

Pretty simple, basically does the following:
- Creates an S3 bucket for the client
- Sets up my buddy, [rob2d's](https://github.com/rob2d) [React/Redux generator](https://github.com/rob2d/generator-react-redux-gulp)
- Sets up the repo
- Builds the React app
- Deploys it to S3
- Sets up a Rails API with the --api flag
- Fixes CORS for hackathons (NOTE: HIGHLY INSECURE, DON'T USE FOR PERMANENT PROJECTS)
- Adds a simple little fix for camelCase vs snake_case with [olive_branch](https://github.com/vigetlabs/olive_branch)
- Deploys to AWS Elastic Beanstalk

## Requirements

This script is set up for my computer (Macbook Pro running macOS Sierra) only,
so I don't promise any compatability with, say Ubuntu or Windows bash.
Basically, the script assumes you have the following set up:

- Node.js v8.1.3
- NPM v5.3.0
- Yeoman 2.0.0
- generator-react-redux-gulp v0.2.7
- Gulp CLI v1.3.0
- Rails v5.1.3
- Ruby v2.4.1
- AWS CLI (with Access Keys and admin, but not root, rights)
- Elastic Beanstalk CLI
- git v2.11.0
