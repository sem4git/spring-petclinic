aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_url}
docker tag 6a7bba1480a1 ${ecr_url}:v1
docker push ${ecr_url}:v1