# EC2 e AWS Systems Manager Session Manager

Laboratório Terraform para demonstrar três formas de acessar uma EC2:
SSH pela internet, Session Manager com saída por NAT Gateway e Session Manager
com AWS PrivateLink. A VPC na raiz fornece a rede necessária aos exemplos.

## Arquitetura

![Arquitetura dos acessos SSH e Session Manager com NAT Gateway e PrivateLink](docs/arch.png)

O diagrama apresenta os caminhos de acesso. Neste laboratório, o PrivateLink usa
os endpoints `ssm` e `ssmmessages`; a rota NAT da subnet compartilhada permanece,
mas o SG da EC2 restringe a saída aos endpoints.

## Os três cenários

| Diretório | Sistema operacional | Rede | Acesso |
| --- | --- | --- | --- |
| `ec2-ssh` | Debian 13 ARM64 | Subnet pública A, com IP público | SSH com chave, TCP 22 restrito ao IP informado |
| `ec2-session-manager-nat-gateway` | Amazon Linux 2023 ARM64 | Subnet privada A, sem IP público | Session Manager, saída HTTPS pelo NAT |
| `ec2-session-manager-private-link` | Amazon Linux 2023 ARM64 | Subnet privada A, sem IP público | Session Manager, saída HTTPS para endpoints privados |

Todas usam `t4g.small` (Graviton2). As EC2 dos exemplos e os endpoints usam somente
a zona A. As subnets B fazem parte da rede de apoio.

```text
SSH:         Notebook -> Internet Gateway -> EC2 Debian (TCP 22)
NAT:         EC2 -> NAT Gateway -> endpoints públicos do Systems Manager
PrivateLink: EC2 -> Interface VPC Endpoints -> Systems Manager
```

No Session Manager, o operador acessa o serviço AWS e o SSM Agent inicia as conexões
a partir da EC2. A instância não precisa de chave SSH nem de regra de entrada TCP 22.
A role da instância usa `AmazonSSMManagedInstanceCore`; as permissões do operador
para iniciar, retomar e encerrar sessões são separadas.

## Preparação

Tenha Terraform, AWS CLI e o Session Manager plugin instalados. Use credenciais
com permissões para criar os recursos do laboratório, publicar e consultar os
parâmetros SSM. Para abrir sessões, a identidade do operador também precisa das
permissões de Session Manager. O código não atribui permissões ao operador.

Existe somente um diretório `live/sandbox`, na raiz:

- `terraform.tfvars`: nomes dos projetos, região, ambiente, tipo de instância e dados SSH.
- `backend.tfvars`: bucket, chave e região do estado S3 da infraestrutura da raiz.

Configure seu perfil AWS e revise esses arquivos. Os nomes do exemplo são:

```hcl
project_name_vpc             = "aws-vpc"
project_name_session_manager = "sessionmanager"
```

Cada diretório EC2 é uma configuração Terraform independente com estado local.
Os blocos vazios de `variables.tf` declaram entradas; seus valores vêm do arquivo
compartilhado. `project_name_vpc` pertence à raiz e não é declarado nos exemplos EC2.
Ao passar o arquivo compartilhado nos exemplos, o Terraform pode emitir
`Value for undeclared variable` para essa entrada. É um aviso esperado, pois ela
não é utilizada nesses diretórios.

## 1. Prepare a rede e publique os parâmetros

Na raiz, configure o bucket existente em `live/sandbox/backend.tfvars` e execute:

```bash
terraform init -backend-config=live/sandbox/backend.tfvars
terraform plan -var-file=live/sandbox/terraform.tfvars -out=tfplan
terraform apply tfplan
```

Se a VPC já foi aplicada, use o mesmo backend e estado. Revise o plano antes de aplicar.
O arquivo `parameters_store.tf` publica os IDs necessários:

| Parâmetro | Uso |
| --- | --- |
| `/sessionmanager/aws-vpc/vpc_id` | Security Groups e endpoints |
| `/sessionmanager/aws-vpc/public_subnet_1a_id` | EC2 SSH |
| `/sessionmanager/aws-vpc/private_subnet_1a_id` | EC2 Session Manager e endpoints |

Os exemplos consultam esses parâmetros usando `data "aws_ssm_parameter"`.
Não é necessário copiar IDs para o `terraform.tfvars`, nem ler o estado S3 da VPC.
A consulta é feita pelo Terraform com as credenciais do operador, na mesma conta
e região da rede. Os parâmetros precisam existir antes do plan dos exemplos.

## 2. Acesso tradicional por SSH

O Terraform gera um par RSA de 4096 bits, registra a chave pública na AWS e salva
a chave privada como `ec2-ssh.pem` dentro do diretório `ec2-ssh`, com permissão `0400`.
O caminho será `<caminho-do-repositorio>/ec2-ssh/ec2-ssh.pem`.
O arquivo é criado pelo apply, na máquina que executa o Terraform. Não é necessário
usar `ssh-keygen` nem informar um arquivo `.pub`.

No `live/sandbox/terraform.tfvars`, configure `ssh_allowed_cidr` com seu IP público
seguido de `/32`. O `.pem`, os estados e os planos estão ignorados pelo Git.
A chave privada também fica no estado Terraform do exemplo SSH; proteja esse arquivo.
O destroy do exemplo remove o arquivo `.pem` gerenciado pelo Terraform.

A partir da raiz:

```bash
cd ec2-ssh
terraform init
terraform plan -var-file=../live/sandbox/terraform.tfvars -out=tfplan
terraform apply tfplan
terraform output -raw instance_id
terraform output -raw ssh_command
```

Execute o comando SSH exibido no output para conectar com a chave `.pem`.
A EC2 Debian recebe IP público. O SG permite entrada TCP 22 da origem configurada;
o tráfego de resposta é permitido automaticamente. Este exemplo não libera saída
para downloads ou atualizações do sistema.

## 3. Session Manager com NAT Gateway

Execute antes de criar os endpoints PrivateLink. A partir da raiz:

```bash
cd ec2-session-manager-nat-gateway
terraform init
terraform plan -var-file=../live/sandbox/terraform.tfvars -out=tfplan
terraform apply tfplan
terraform output -raw session_manager_command
```

Execute o comando `aws ssm start-session ...` exibido pelo output. Aguarde o agente
registrar a instância no Systems Manager; a conclusão do apply não garante que
ela já esteja online.

A instância permite saída TCP 443 e utiliza a rota NAT da subnet privada A.
Ela não recebe IP público e não tem regras de entrada no SG.

Destrua este exemplo antes de iniciar o cenário PrivateLink:

```bash
terraform plan -destroy -var-file=../live/sandbox/terraform.tfvars -out=tfplan.destroy
terraform apply tfplan.destroy
```

## 4. Session Manager com AWS PrivateLink

A partir da raiz:

```bash
cd ec2-session-manager-private-link
terraform init
terraform plan -var-file=../live/sandbox/terraform.tfvars -out=tfplan
terraform apply tfplan
terraform output -raw session_manager_command
```

Execute o comando de conexão exibido. Este cenário cria os endpoints `ssm` e
`ssmmessages` na subnet privada A, com DNS privado habilitado. O SG da EC2 permite
saída HTTPS apenas para o SG dos endpoints, que aceita entrada apenas dessa EC2.

A rota NAT da subnet continua existindo, mas a comunicação SSM deste exemplo
utiliza os endpoints. O laboratório demonstra PrivateLink na rede compartilhada.

O DNS privado afeta toda a VPC. Se o exemplo NAT permanecer ativo, os nomes SSM
passarão a resolver para os endpoints privados, cujo SG não permite essa outra EC2.
Por isso os cenários NAT e PrivateLink são demonstrados em sequência.

Os dois exemplos usam sessões shell padrão, sem configurar gravação em S3 ou
CloudWatch Logs nem criptografia KMS personalizada. Preferências de sessão que
exijam esses serviços precisam de permissões e conectividade adicionais.

## Consultar IDs e comandos sem usar o console

Dentro de qualquer diretório `ec2-*`, depois do apply:

```bash
terraform output -raw instance_id
terraform output -raw private_ip
```

No exemplo SSH, `terraform output -raw ssh_command` mostra a conexão com a chave
`.pem`; `terraform output -raw private_key_path` mostra onde ela foi salva.
Nos exemplos Session Manager, `terraform output -raw session_manager_command`
mostra o comando `aws ssm start-session` com região e ID da instância.
Nenhum output exibe o conteúdo da chave privada.

## Decisões do código

- **`data.tf`:** agrupa consultas a recursos existentes. `resource` gerencia recursos;
  `data` consulta informações, como os IDs publicados no Parameter Store.
- **AMI Debian:** consulta a imagem Debian 13 ARM64 na conta oficial do Debian.
- **AMI Amazon Linux:** consulta o parâmetro público mantido pela AWS
  `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64`.
  O valor é o ID regional da AMI padrão AL2023 ARM64. A consulta não configura
  o Session Manager; apenas seleciona a imagem. Novas AMIs podem provocar uma
  proposta de substituição da EC2 em planos futuros.
- **SSM Agent:** a AMI padrão inclui o agente. O `user_data` atual habilita e inicia
  seu serviço; não instala pacotes. Se o serviço já estiver habilitado e ativo,
  esse comando é redundante.
- **`depends_on`:** aguarda permissões IAM e, no PrivateLink, endpoints e regras
  de rede antes de criar a EC2. Essas dependências não são todas inferidas das
  referências diretas. Isso não elimina o tempo de propagação dos serviços AWS.
- **`metadata_options`:** `http_tokens = "required"` exige IMDSv2 para consultar
  metadados e credenciais temporárias da role na EC2.

## Remoção

Em cada diretório EC2 que tiver sido aplicado:

```bash
terraform plan -destroy -var-file=../live/sandbox/terraform.tfvars -out=tfplan.destroy
terraform apply tfplan.destroy
```

Depois de remover todos os exemplos, se também quiser remover a infraestrutura
de apoio, execute na raiz:

```bash
terraform plan -destroy -var-file=live/sandbox/terraform.tfvars -out=tfplan.destroy
terraform apply tfplan.destroy
```

Cada diretório tem seu estado: destruir a raiz não destrói automaticamente as EC2.
NAT Gateways, endpoints, instâncias, discos e IPv4 público podem gerar cobranças.

## Referências

- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Endpoints para Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html)
- [AMIs AL2023 e parâmetros públicos](https://docs.aws.amazon.com/linux/al2023/ug/ec2.html)
- [SSM Agent nas AMIs e verificação do serviço](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html)
- [Debian 13 na EC2](https://wiki.debian.org/Cloud/AmazonEC2Image/Trixie)
- [IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-IMDS-new-instances.html)
- [Dependências explícitas no Terraform](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)
