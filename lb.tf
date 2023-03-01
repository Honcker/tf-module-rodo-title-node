resource "aws_lb" "rodo-title-lb" {
  //count              = 1
  name = "${local.node_slug}-title-lb"
  # 32 character limit for this name limits the number of characters for var.environment
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rodo-title-alb-sg.id]
  subnets = [
    "${aws_subnet.public-subnets[0].id}",
    "${aws_subnet.public-subnets[1].id}",
  ]

  tags = local.default__tags
}

resource "aws_lb_target_group" "rodo-title-proxy-tg-group" {
  name = "${local.node_slug}-title-tg"
  # 32 character limit for this name limits the number of characters for var.environment
  port        = "8081"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rodo-title.id
  target_type = "ip"

  health_check {
    path = "/healthcheck"
  }

  tags = merge(local.default__tags,
    {
      desc = "lb target group for ${local.node_name} rodo title server"
  })

  depends_on = [aws_lb.rodo-title-lb]
}

resource "aws_lb_listener" "rodo-title-proxy-lb-listener" {
  load_balancer_arn = aws_lb.rodo-title-lb.arn
  port              = "80"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.public_wildcard.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rodo-title-proxy-tg-group.arn
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-rodo-title-proxy-listener"
  })

  depends_on = [
    aws_acm_certificate_validation.public_wildcard
    # LB can fail to provision if cert isn't ready for listener
  ]
}

resource "aws_lb_listener" "rodo-title-proxy-lb-ssl-listener" {
  load_balancer_arn = aws_lb.rodo-title-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.public_wildcard.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rodo-title-proxy-tg-group.arn
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-rodo-title-proxy-ssl-listener"
  })

  depends_on = [
    aws_acm_certificate_validation.public_wildcard
    # LB can fail to provision if cert isn't ready for listener
  ]
}


resource "aws_lb" "corda-lb" {
  name               = "${local.node_slug}-corda-lb"
  internal           = true
  load_balancer_type = "network"
  subnets = [
    # aws_subnet.rodo-title-private-1.id
    aws_subnet.private-subnets[0].id
  ]

  tags = local.default__tags
}

locals {
  corda_ports = {
    madison  = "10018"
    toyota   = "10015"
    hamilton = "10006"
  }
  corda_short_codes = {
    madison  = "mad"
    toyota   = "toy"
    hamilton = "ham"
  }
}

resource "aws_lb_target_group" "corda" {
  for_each = local.corda_ports

  # 32 character limit for this name limits the number of characters for var.environment
  name     = "${local.node_slug}-corda-${local.corda_short_codes[each.key]}"
  port     = each.value
  protocol = "TCP"
  vpc_id   = aws_vpc.rodo-title.id

  tags = merge(local.default__tags,
    {
      client_name       = each.key
      client_short_code = local.corda_short_codes[each.key]
  })

  depends_on = [aws_lb.corda-lb]
}

resource "aws_lb_listener" "corda-lb-listener" {
  for_each          = local.corda_ports
  load_balancer_arn = aws_lb.corda-lb.arn
  port              = each.value
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.corda[each.key].arn
  }

  tags = merge(local.default__tags,
    {
      Name = "rodo-title-corda-listener"
  })
}

resource "aws_lb_target_group_attachment" "corda" {
  for_each         = local.corda_ports
  target_group_arn = aws_lb_target_group.corda[each.key].arn
  target_id        = aws_instance.rodo-title-CorApp[0].id
  port             = each.value
}

resource "aws_vpc_endpoint_service" "corda" {
  count                      = var.opt_corda_vpc_endpoint_enabled ? 1 : 0
  acceptance_required        = false
  allowed_principals         = local.corda_vpc_principals
  network_load_balancer_arns = [aws_lb.corda-lb.arn]
}
