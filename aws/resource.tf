###### CREATE ROLE USING TERRAFORM WITH POLICY TO ACCESS S3 #####################

# create role 
#the policy that grants an entity permissions to assume the role.  
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#IAM role policy
#Inline policy
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


#attach iam policy to iam role 

resource "aws_iam_role_policy_attachment" "test-attach" {
    role       = "${aws_iam_role.test_role.name}"
    policy_arn = "arn:aws:iam::014113151286:policy/harish_AmazonS3ReadOnlyAccess"
}

