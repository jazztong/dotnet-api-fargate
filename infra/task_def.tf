resource "aws_ecs_task_definition" "this" {
  family                   = "sample_api"
  memory                   = 512
  cpu                      = 256
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  container_definitions = jsonencode(
    [{
      "name" : "my-api"
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/sample_api",
      "portMappings" : [
        { containerPort = 80 }
      ],
    }]
  )
}
