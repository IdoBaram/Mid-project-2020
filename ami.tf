locals {
  iam_name = "mid_course_consul_join"
}

resource "aws_iam_role" "consul_join" {
  name               = local.iam_name
  assume_role_policy = file("./templates/policies/assume-role.json")
}

resource "aws_iam_policy" "consul_join" {
  name        = local.iam_name
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("./templates/policies/describe-instances.json")
}

resource "aws_iam_policy_attachment" "consul_join" {
  name       = local.iam_name
  roles      = ["${aws_iam_role.consul_join.name}"]
  policy_arn = aws_iam_policy.consul_join.arn
}

resource "aws_iam_instance_profile" "consul_join" {
  name  = local.iam_name
  role  = aws_iam_role.consul_join.name
}