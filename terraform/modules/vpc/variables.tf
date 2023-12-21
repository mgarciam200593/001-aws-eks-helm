variable "networks" {
  type = object({
    cidr_block               = string
    private_subnets          = optional(list(string), [])
    private_azs              = optional(list(string), [])
    public_subnets           = optional(list(string), [])
    public_azs               = optional(list(string), [])
    create_igw               = optional(bool, false)
    create_natgw             = optional(bool, false)
    public_subnet_tags       = optional(map(string), { Name = "" })
    private_subnet_tags      = optional(map(string), { Name = "" })
    public_route_table_tags  = optional(map(string), { Name = "" })
    private_route_table_tags = optional(map(string), { Name = "" })
    igw_tags                 = optional(map(string), {})
    natgw_tags               = optional(map(string), {})
    eip_tags                 = optional(map(string), {})
  })
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}
