# Ansible

Container Docker com Ansible para gerenciamento de servidores via SSH.

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando
- Chave `.pem` de acesso aos servidores na raiz do projeto
- Acesso de rede aos servidores (VPN ou rede interna)

## Estrutura

```
ansible/
├── Dockerfile
├── docker-compose.yml
├── ansible.cfg
├── inventory/
│   └── hosts.ini        # IPs e grupos de servidores
├── playbooks/
│   ├── ping.yml         # Testa conectividade
│   └── info.yml         # Coleta informações dos servidores
├── group_vars/
│   └── all.yml          # Variáveis globais
└── roles/               # Roles Ansible (adicionar conforme necessário)
```

## Configuração

### 1. Chave SSH

Coloque a chave `.pem` na raiz do projeto:

```
ansible/
└── AcessoDesenvolvedor.pem
```

> A chave está no `.gitignore` e nunca será commitada.

### 2. Inventário

Edite `inventory/hosts.ini` com os IPs dos seus servidores:

```ini
[webservers]
web01 ansible_host=10.0.1.10 ansible_user=ubuntu
web02 ansible_host=10.0.1.11 ansible_user=ubuntu

[databases]
db01 ansible_host=10.0.2.10 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=/root/.ssh/AcessoDesenvolvedor.pem
ansible_python_interpreter=/usr/bin/python3
```

Os grupos (`[webservers]`, `[databases]`) são livres — nomeie conforme sua infraestrutura.

**Usuários comuns por AMI:**
| AMI | Usuário |
|-----|---------|
| Ubuntu | `ubuntu` |
| Amazon Linux | `ec2-user` |
| RHEL | `ec2-user` |
| Debian | `admin` |

## Uso

### Build da imagem (apenas na primeira vez ou após alterar o Dockerfile)

```powershell
docker compose build
```

### Entrar no container

```powershell
docker compose run --rm ansible bash
```

### Testar conectividade

```bash
ansible all -m ping -i inventory/hosts.ini
```

### Rodar playbooks

```bash
# Coletar informações dos servidores
ansible-playbook playbooks/info.yml

# Rodar em um grupo específico
ansible-playbook playbooks/ping.yml --limit webservers

# Rodar em um host específico
ansible-playbook playbooks/ping.yml --limit web01

# Dry-run (sem executar de fato)
ansible-playbook playbooks/ping.yml --check
```

### Comandos ad-hoc úteis

```bash
# Uptime de todos os servidores
ansible all -m shell -a "uptime"

# Uso de disco
ansible all -m shell -a "df -h"

# Uso de memória
ansible all -m shell -a "free -m"

# Reiniciar um serviço
ansible webservers -m service -a "name=nginx state=restarted" --become
```

## Trocar a chave SSH

Se a nova chave tiver o **mesmo nome**:
```powershell
Copy-Item C:\caminho\nova-chave.pem .\AcessoDesenvolvedor.pem
```

Se tiver **nome diferente**, atualize os arquivos:
- `docker-compose.yml` → volume da chave
- `ansible.cfg` → `private_key_file`
- `inventory/hosts.ini` → `ansible_ssh_private_key_file`

## Adicionar novos playbooks

Crie um arquivo em `playbooks/` e rode:

```bash
ansible-playbook playbooks/meu-playbook.yml
```

O diretório `playbooks/` é montado como volume — qualquer arquivo salvo no host aparece imediatamente dentro do container, sem precisar rebuildar.
