#
#
# @Braim T (braimt@gmail.com)

data "aws_caller_identity" "me" {}


# Start by provisioning an S3 bucket.
resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name

  force_destroy = true

  tags = { Name = local.bucket_name }
}

# disable versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {

  bucket = aws_s3_bucket.my_bucket.bucket

  versioning_configuration {
    status = "Disabled"
  }
}

# make the bucket private
resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.bucket
  acl    = "private"
}

# create an input and an output folder in my buckets
resource "aws_s3_object" "my_bucket_folders" {

  for_each = toset(["input", "output"])

  bucket = aws_s3_bucket.my_bucket.bucket
  acl    = "private"
  key    = format("%s/", each.key)
}

# upload a file to the bucket
resource "aws_s3_object" "my_bucket_object" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "input/imdb.name.basics.tsv"
  source = "./assets/name.basics.tsv.10k"

  etag = filemd5("./assets/name.basics.tsv.10k")
}


# Now that we have uploaded the file to the bucket, we need to configure aws glue
# to define the database and the table. Since this is related to IMDb datasets, 
# I decided to call it imdb.
resource "aws_glue_catalog_database" "my_imdb_glue_database" {
  name = "my-imdb-database"
}

# define the table and its structure.
resource "aws_glue_catalog_table" "my_glue_catalog_table" {
  name          = "imdb-name-basics-table"
  database_name = aws_glue_catalog_database.my_imdb_glue_database.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = format("s3://%s/input", local.bucket_name)
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.mapred.TextInputFormat"

    # The uploaded file is a tab separated values.
    ser_de_info {
      name                  = "my-ser-de-for-tab"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = "\t"
        "skip.header.line.count" = 1 # Skip file headers
      }
    }

    # the different columns
    columns {
      name    = "nconst"
      type    = "string"
      comment = "alphanumeric unique identifier of the name/person"
    }

    columns {
      name    = "primaryName"
      type    = "string"
      comment = "name by which the person is most often credited"
    }

    columns {
      name    = "birthYear"
      type    = "int"
      comment = "in YYYY format"
    }

    columns {
      name    = "deathYear"
      type    = "int"
      comment = "in YYYY format if applicable"
    }

    columns {
      name    = "primaryProfession"
      type    = "string"
      comment = "the top-3 professions of the person"
    }

    columns {
      name    = "knownForTitles"
      type    = "string"
      comment = "titles the person is known for"
    }
  }
}

# Now we need to define a workgroup. These workgroups allows us to "group" and set some limits on queries 
# that are being executed later within it. Also, it specifies an output bucket.
resource "aws_athena_workgroup" "my_athena_workgroup" {
  name = "my-imdb-workgroup"

  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = format("s3://%s/output/", local.bucket_name)
    }
  }
}