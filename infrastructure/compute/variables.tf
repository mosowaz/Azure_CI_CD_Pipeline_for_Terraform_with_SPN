variable "location1" {
  type    = string
  default = "canadacentral"
}

variable "location2" {
  type    = string
  default = "canadaeast"
}

variable "hub-sshkey" {}      # environment variable to be passed from pipeline (key vault)
variable "hub-sshkey-pub" {}       # environment variable to be passed from pipeline (key vault)
variable "sp1-sshkey" {}   # environment variable to be passed from pipeline (key vault)
variable "sp1-sshkey-pub" {}    # environment variable to be passed from pipeline (key vault)
variable "sp2-sshkey" {}   # environment variable to be passed from pipeline (key vault)
variable "sp2-sshkey-pub" {}    # environment variable to be passed from pipeline (key vault)