pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {

        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/JayLikhare316/redisdemo.git', branch: 'master'
            }
        }

        stage('Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        echo "=== Terraform Init ==="
                        cd terraform/
                        terraform init

                        echo "=== Terraform Validate ==="
                        terraform validate

                        echo "=== Terraform Plan ==="
                        terraform plan -out=tfplan
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'terraform/tfplan', allowEmptyArchive: true
                }
            }
        }

        stage('Apply/Destroy') {
            when {
                expression { return params.autoApprove }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        if (params.action == 'apply') {
                            sh '''
                                echo "=== Pre-deployment Setup ==="
                                # Create key pair if it doesn't exist
                                if ! aws ec2 describe-key-pairs --key-names my-key-aws --region ap-south-1 >/dev/null 2>&1; then
                                    echo "Creating key pair 'my-key-aws'..."
                                    aws ec2 create-key-pair --key-name my-key-aws --region ap-south-1 --query 'KeyMaterial' --output text > my-key-aws.pem
                                    chmod 400 my-key-aws.pem
                                    echo "Key pair created successfully!"
                                else
                                    echo "Key pair 'my-key-aws' already exists."
                                fi
                                
                                echo "=== Terraform Apply ==="
                                cd terraform/
                                terraform apply tfplan
                            '''
                        } else if (params.action == 'destroy') {
                            sh '''
                                echo "=== Terraform Destroy ==="
                                cd terraform/
                                terraform destroy --auto-approve
                            '''
                        }
                    }
                }
            }
        }

        stage('Wait for Infrastructure') {
            when {
                allOf {
                    expression { return params.autoApprove }
                    expression { return params.action == 'apply' }
                }
            }
            steps {
                echo "=== Waiting for infrastructure to be ready ==="
                sleep time: 60, unit: 'SECONDS'
            }
        }

        stage('Run Ansible Playbook') {
            when {
                allOf {
                    expression { return params.autoApprove }
                    expression { return params.action == 'apply' }
                }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        echo "=== Running Ansible Playbook ==="
                        
                        # Use the key pair created during deployment
                        if [ -f "my-key-aws.pem" ]; then
                            chmod 400 my-key-aws.pem
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            echo "Running Ansible with my-key-aws.pem"
                            ansible-playbook -i aws_ec2.yaml playbook.yml --private-key=my-key-aws.pem
                        else
                            echo "Key file my-key-aws.pem not found. Skipping Ansible deployment."
                            echo "You can run Ansible manually later with the key pair."
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo 'Pipeline failed!'
            // Add notification logic here
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
