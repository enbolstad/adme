resource "null_resource" "delete_private_dns_link_for_energy" {
  triggers = {
    rg        = azurerm_resource_group.default.name
    zone_name = "privatelink.energy.azure.com"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      LINKS=$(az network private-dns link vnet list --resource-group "${self.triggers.rg}" --zone-name "${self.triggers.zone_name}" --query "[].[name]" -o tsv)
      for link in $LINKS
      do
        az network private-dns link vnet delete --name $link --resource-group ${self.triggers.rg} --zone-name ${self.triggers.zone_name} -y
      done
    EOT
  }

  depends_on = [
    azurerm_resource_group.default,
    azurerm_virtual_network.adme,
    azurerm_subnet.adme
  ]
}

resource "null_resource" "delete_private_dns_link_for_blob" {
  triggers = {
    rg        = azurerm_resource_group.default.name
    zone_name = "privatelink.blob.core.windows.net"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      LINKS=$(az network private-dns link vnet list --resource-group "${self.triggers.rg}" --zone-name "${self.triggers.zone_name}" --query "[].[name]" -o tsv)
      for link in $LINKS
      do
        az network private-dns link vnet delete --name $link --resource-group ${self.triggers.rg} --zone-name ${self.triggers.zone_name} -y
      done
    EOT
  }

  depends_on = [
    azurerm_resource_group.default,
    azurerm_virtual_network.adme,
    azurerm_subnet.adme
  ]
}