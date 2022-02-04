# TerraformAPI

    
    aws configure set aws_secret_access_key EfphT6SGkTRbwH8k/V3axnB0+TBvIn0RiD/R/A6W --profile default
    
    aws configure set aws_access_key_id AKIAI44QH8DHBEXAMPLE --profile default




### TFenv

brew unlink terraform
brew install tfenv
tfenv list-remote
tfenv install 0.14.11
tfenv use 0.14.11

### kinesis
https://aws.amazon.com/blogs/aws/introducing-amazon-kinesis-data-analytics-studio-quickly-interact-with-streaming-data-using-sql-python-or-scala/?sc_channel=EL&sc_campaign=Demo_Deep_Dive_2021_vid&sc_medium=YouTube&sc_content=Video9639&sc_detail=ANALYTICS&sc_country=US


aws iam list-attached-role-policies --role-name iam_for_lambda
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonKinesisFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
        }
    ]
}



#######To Do
- Jak zaciagac zmiany w funkcjalch lambdowych?:wq


