locals {
  landscape = yamldecode(file(var.landscape_file))
  settings = lookup(local.landscape, "settings", {})
  structure = local.landscape["structure"]
  modules = yamldecode(file(var.modules_file))
}

locals {
  config_defaults = { for k, v in local.structure : k => v if k != "realms" && k != "foundations" }
  l0_foundations = {
    for foundation, foundation_details in lookup(local.structure, "foundations", {}) : foundation => merge(
      local.config_defaults,
      {
        repository_name = foundation
      },
      foundation_details,
      {
        name = foundation
        parent = "root"
      }
    )
  }
  l1_realms = {
    for realm, realm_details in lookup(local.structure, "realms", {}) : realm => merge(
      { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
      {
        name = realm
        parent = "root"
      }
    )
  }
  l1_foundations = {
    for idx, pair in flatten([
      for realm, realm_details in lookup(local.structure, "realms", {}) : [
        for foundation, foundation_details in lookup(realm_details, "foundations", {}) : merge(
          local.config_defaults,
          { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
          {
            repository_name = foundation
          },
          foundation_details,
          {
            parent = realm
            name = foundation
          }
        )
      ]
    ]) : "${pair.parent}/${pair.name}" => pair
  }
  l2_realms = {
    for idx, pair in flatten([
      for realm, realm_details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(realm_details, "realms", {}) : merge(
          { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
          { for k, v in sub_details : k => v if k != "realms" && k != "foundations" },
          {
            parent = realm
            name = sub_realm
          }
        )
      ]
    ]) : "${pair.parent}/${pair.name}" => pair
  }
  l2_foundations = {
    for idx, pair in flatten([
      for realm, realm_details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(realm_details, "realms", {}) : [
          for foundation, foundation_details in lookup(sub_details, "foundations", {}) : merge(
            local.config_defaults,
            { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
            { for k, v in sub_details : k => v if k != "realms" && k != "foundations" },
            {
              repository_name = foundation
            },
            foundation_details,
            {
              parent = "${realm}/${sub_realm}"
              name = foundation
            }
          )
        ]
      ]
    ]) : "${pair.parent}/${pair.name}" => pair
  }
  l3_realms = {
    for idx, pair in flatten([
      for realm, realm_details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(realm_details, "realms", {}) : [
          for bis_realm, bis_details in lookup(sub_details, "realms", {}) : merge(
            { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
            { for k, v in sub_details : k => v if k != "realms" && k != "foundations" },
            { for k, v in bis_details : k => v if k != "realms" && k != "foundations" },
            {
              parent = "${realm}/${sub_realm}"
              name = bis_realm
            }
          )
        ]
      ]
    ]) : "${pair.parent}/${pair.name}" => pair
  }
  l3_foundations = {
    for idx, pair in flatten([
      for realm, realm_details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(realm_details, "realms", {}) : [
          for bis_realm, bis_details in lookup(sub_details, "realms", {}) : [
            for foundation, foundation_details in lookup(bis_details, "foundations", {}) : merge(
              local.config_defaults,
              { for k, v in realm_details : k => v if k != "realms" && k != "foundations" },
              { for k, v in sub_details : k => v if k != "realms" && k != "foundations" },
              { for k, v in bis_details : k => v if k != "realms" && k != "foundations" },
              {
                repository_name = foundation
              },
              foundation_details,
              {
                parent = "${realm}/${sub_realm}/${bis_realm}"
                name = foundation
              }
            )
          ]
        ]
      ]
    ]) : "${pair.parent}/${pair.name}" => pair
  }
}

locals {
  realms = merge(local.l1_realms, local.l2_realms, local.l3_realms)
  foundations = merge(local.l0_foundations, local.l1_foundations, local.l2_foundations, local.l3_foundations)
}
