resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}

######## LAMBDA #############

resource "aws_iam_role" "iam_for_lambda_kinesis" {
  name = "iam_for_lambda_kinesis"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kinesis:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.iam_for_lambda_kinesis.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_function" "test_lambdaforkinesis" {
  filename      = "lambda_scripts/random_data_generator.zip"
  function_name = "lambda_for_kinesis"
  role          = aws_iam_role.iam_for_lambda_kinesis.arn
 

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("example.zip"))}"
  source_code_hash = filebase64sha256("lambda_scripts/random_data_generator.zip")

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "random_data_generator.handler"  
  runtime = "python3.7"
  publish = true
  timeout = 900


  environment {
    variables = {
      foo = "bar"
      name2 = "example"
    }
  }
}


#############GLUE

resource "aws_glue_catalog_database" "glue_db" {
  name = "gluedb"
}


##############KINESIS ANALYTICs




resource "aws_kinesisanalyticsv2_application" "example" {
  name                   = "example-sql-application"
  runtime_environment    = "SQL-1_0"
  service_execution_role = aws_iam_role.iam_for_lambda_kinesis2.arn

  application_configuration {
    application_code_configuration {
      code_content {
        text_content = "SELECT 1;\n"
      }

      code_content_type = "PLAINTEXT"
    }

    sql_application_configuration {
      input {
        name_prefix = "PREFIX_1"

        input_parallelism {
          count = 3
        }

        input_schema {
          record_column {
            name     = "COLUMN_1"
            sql_type = "VARCHAR(8)"
            mapping  = "MAPPING-1"
          }

          record_column {
            name     = "COLUMN_2"
            sql_type = "DOUBLE"
          }

          record_encoding = "UTF-8"

          record_format {
            record_format_type = "CSV"

            mapping_parameters {
              csv_mapping_parameters {
                record_column_delimiter = ","
                record_row_delimiter    = "\n"
              }
            }
          }
        }

        kinesis_streams_input {
          resource_arn = aws_kinesis_stream.test_stream.arn
        }
      }



    }
  }

}



resource "aws_iam_role" "iam_for_lambda_kinesis2" {
  name = "iam_for_lambda_kinesis2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "kinesisanalytics.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy2" {
  name        = "test-policy2"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kinesis:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach2" {
  role       = aws_iam_role.iam_for_lambda_kinesis2.name
  policy_arn = aws_iam_policy.policy2.arn
}



###########

data "archive_file" "init" {
  type        = "zip"
  source_file = "sensor.sql"
  output_path = "sensor.zip"
}


resource "aws_s3_bucket" "example" {
  bucket = "example-flink-application"
}

resource "aws_s3_bucket_object" "example" {
  bucket = aws_s3_bucket.example.bucket
  key    = "example-flink-application"
  source = "sensor.sql"
}

######################

#resource "aws_kinesisanalyticsv2_application" "example4" {
#  name                   = "example-flink-application"
#  runtime_environment    = "FLINK-1_8"
#  service_execution_role = aws_iam_role.iam_for_lambda_kinesis2.arn

#  application_configuration {
#    application_code_configuration {
#    code_content {
#        s3_content_location {
#          bucket_arn = aws_s3_bucket.example.arn
#          file_key   = aws_s3_bucket_object.example.key
#        }
#      }

#      code_content_type = "ZIPFILE"
#    }

#    environment_properties {
#      property_group {
#        property_group_id = "PROPERTY-GROUP-1"

#        property_map = {
#          Key1 = "Value1"
#        }
#      }

#      property_group {
#        property_group_id = "PROPERTY-GROUP-2"

#        property_map = {
#          KeyA = "ValueA"
#          KeyB = "ValueB"
#        }
#      }
#    }

#    flink_application_configuration {
#      checkpoint_configuration {
#        configuration_type = "DEFAULT"
#      }

#      monitoring_configuration {
#        configuration_type = "CUSTOM"
#        log_level          = "DEBUG"
#        metrics_level      = "TASK"
#      }

#      parallelism_configuration {
#        auto_scaling_enabled = true
#        configuration_type   = "CUSTOM"
#        parallelism          = 10
#        parallelism_per_kpu  = 4
#      }
#    }
#  }

#  tags = {
#    Environment = "test"
#  }
#}