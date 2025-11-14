output "jenkins_url" {
  value = helm_release.jenkins.status[0].name
}
