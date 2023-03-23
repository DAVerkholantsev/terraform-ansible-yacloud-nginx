#create subnet
resource "yandex_vpc_subnet" "interlink" {
  name			= "nginx"
  zone			= "ru-central1-a"
  network_id		= "${yandex_vpc_network.interlink.id}"
  v4_cidr_blocks	= ["10.5.0.0/24"]

}


resource "yandex_compute_instance" "vm-1" {
  name		= "vm1"
  platform_id	= "standard-v1"
  zone		= "ru-central1-a"
  allow_stopping_for_update	= true
  resources {
    cores		= 2
    memory		= 1
    core_fraction	= 5
  }
  scheduling_policy {
    preemptible	= true
  }

  boot_disk {
    initialize_params {
      image_id	= "fd8emvfmfoaordspe1jr"
      size	= 10
    }
  }

  network_interface {
    subnet_id	= "${yandex_vpc_subnet.interlink.id}"
    ip_address	= "10.5.0.3"
    nat		= true
  }

  metadata = {
    user-data = "${file("meta.yml")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name		= "vm2"
  platform_id	= "standard-v1"
  zone		= "ru-central1-a"
  allow_stopping_for_update	= true
  resources {
    cores		= 2
    memory		= 1
    core_fraction	= 5
  }
  scheduling_policy {
    preemptible	= true
  }

  boot_disk {
    initialize_params {
      image_id	= "fd8emvfmfoaordspe1jr"
      size	= 10
    }
  }

  network_interface {
    subnet_id	= "${yandex_vpc_subnet.interlink.id}"
    ip_address	= "10.5.0.4"
    nat		= true
  }

  metadata = {
    "serial-port-enable"	= "1"
    user-data			= "${file("meta.yml")}"
  }
}



resource "yandex_lb_network_load_balancer" "lb-nginx" {
  name = "lb-nginx"

  listener {
    name = "listener-web-servers"
    port = 23344
    target_port = 80
    protocol = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web-servers.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_lb_target_group" "web-servers" {
  name = "web-servers-target-group"
  region_id  = "ru-central1"
  target {
    subnet_id = yandex_vpc_subnet.interlink.id
    address   = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.interlink.id
    address   = yandex_compute_instance.vm-2.network_interface.0.ip_address
  }
}
