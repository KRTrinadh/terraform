
variable "aws_access_key" {}
variable "aws_secret_access_key" {}
 variable "bucket_name" {}
provider "aws" {
  region                  = "us-east-1"
}


resource "aws_key_pair" "shiva_key" {
  key_name   = "shiva-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+gBwyOeLmENKDNpxdrOW5N4UUKLb1xC6UmyYHJojqojlpngCU9Yd1COu1cgD73lTOLzIjDSXKyavgqs+0nxI4xEruY89Xw8GBTzOlGK+7NP/teTyshmp48Z98fSKUbw8lB+ZjZt30LoYbJuYl1bmPK0ys9iyBMw8f1W69Ywo2Cq5mjykUUZCkWylYymk4zlfDY0cIIRQxyGbBbEC/p9SPVli9UKedeSBAhagM9X2n1BFP0Djx9dKpZ3rbfKnv/xYDAjXKyRU85C1MEtwoT+dh+uahY/y02/zy58Z2msAdQnYg2f9M9yuSyHKCdMr8WTv8OT09V0MFcnCPI9xkG3ZF root@pc-VirtualBox"
}

resource "template_file" "web-userdata" {
   template = "user-data.web"
}

resource "template_file" "url" {
   template = "script.sh"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "foobar" {
  name  = "shiva_launchin_group1"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.shiva_key.id}" 
  user_data = "${template_file.web-userdata.rendered}" 
  user_data = "${template_file.url.rendered}" 
  provisioner "file" {
    source      = "empty"
    destination = "/tmp/empty"
connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "harish"
  }
  } 


}

resource "aws_autoscaling_group" "bar" {
  availability_zones        = ["us-east-1a"]
  name                      = "foobar3-terraform-test"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.foobar.name}"

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 60
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

  }
}

resource "aws_iam_role" "web_iam_role" {
    name = "web_iam_role"
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

resource "aws_iam_instance_profile" "web_instance_profile" {
    name = "web_instance_profile"
    role = "web_iam_role"
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
  name = "web_iam_role_policy"
  role = "${aws_iam_role.web_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "apps_bucket" {
    bucket = "${var.bucket_name}"
    acl = "public-read"
    versioning {
            enabled = true
    }
    tags {
        Name = "${var.bucket_name}"
    }
}

resource "aws_s3_bucket_object" "bucket_object" {
  key                    = "key1"
  bucket                 = "${var.bucket_name}"
  source                 = "/tmp/empty"
}


  /*provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/usr/bin/curl http://169.254.169.254/latest/meta-data >> /tmp/script.sh",
    ]
  } */
