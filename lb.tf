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
  name                             = "${local.node_slug}-corda-lb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = aws_subnet.public-subnets[*].id
  enable_cross_zone_load_balancing = true
  tags                             = local.default__tags
}

resource "aws_lb_listener" "corda-lb-listener" {
  for_each = aws_lb_target_group.corda

  load_balancer_arn = aws_lb.corda-lb.arn
  port              = each.value.port
  protocol          = "TCP"

  tags = merge(local.default__tags,
    {
      Name = "rodo-title-corda-listener"
  })
  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_lb_target_group" "corda" {
  for_each = local.corda_ports

  name        = "${local.node_slug}-${each.key}"
  target_type = "ip"
  protocol    = "TCP"
  port        = each.value
  vpc_id      = aws_vpc.rodo-title.id
}
