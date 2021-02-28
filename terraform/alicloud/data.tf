#===============================================================================
# Data
#===============================================================================
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_images" "images" {
  most_recent = true
  name_regex  = "^ubuntu_18_*"
}
