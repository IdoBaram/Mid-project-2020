data "template_file" "hosts" {
  template   = "${file("${path.module}/ansible/hosts.cfg")}"
  depends_on = [
    "aws_instance.jenkins_master",
    "aws_instance.jenkins_agent"
  ]
  vars = {
    jenkins_master = "${join("\n", aws_instance.jenkins_master.*.private_ip)}"
    jenkins_agent  = "${join("\n", aws_instance.jenkins_agent.*.private_ip)}"
  }
}

resource "null_resource" "hosts" {
  triggers = {
    template_rendered = "${data.template_file.hosts.rendered}"
  }
  provisioner "local-exec" {
    interpreter = ["sh", "-c"]
    command     = "echo '${data.template_file.hosts.rendered}' > ./hosts"
  }
}