# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REMOTE STATE BACKEND — Google Cloud Storage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stores Terraform state in a versioned GCS bucket with a scoped prefix.
#
# PREREQUISITES:
#   1. Create the bucket manually or via a bootstrap script:
#        gsutil mb -p <PROJECT_ID> -l <REGION> gs://<BUCKET_NAME>
#        gsutil versioning set on gs://<BUCKET_NAME>
#   2. Replace the placeholder values below with your actual bucket name.
#
# State locking is handled natively by the GCS backend.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  backend "gcs" {
    bucket = "YOUR_STATE_BUCKET_NAME" # ❗ Replace with your GCS bucket name
    prefix = "terraform/state"
  }
}
