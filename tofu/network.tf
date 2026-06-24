resource "yandex_vpc_network" "pxc" {
  name = "${var.name_prefix}-network"
}

resource "yandex_vpc_gateway" "nat" {
  name = "${var.name_prefix}-nat-gateway"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "${var.name_prefix}-private-routes"
  network_id = yandex_vpc_network.pxc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "pxc" {
  for_each = var.subnets

  name           = "${var.name_prefix}-subnet-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.pxc.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = yandex_vpc_route_table.private.id
}
