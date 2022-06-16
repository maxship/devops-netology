variable "cloud_id" {
    type    = string
}

variable "folder_id" {
    type    = string
}

variable "zone" {
    type    = string
    default = "ru-central1-a"
    description = "availability zone"
}

variable "cig_count" {
    type    = number
    default = 3
}
