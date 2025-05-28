#!/bin/bash

# Dar permissão:
# sudo chmod +x docker_cleanup.sh

# Verificar Permissão:
# sudo ls -l docker_cleanup.sh

# Executar
# sudo ./docker_cleanup.sh

# 🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
# VARIÁVEIS

set -e # interrompe o script ao encontrar qualquer erro
# set -x  # Descomentar para ver log completo

# Modo debug roda somente o módulo de verificação
modo_debug=true

# Variável para reiniciar o docker após finalização do script
reiniciar_docker=false

# Variável para executar etapa extra do Airflow
airflow=false
reiniciar_containers=false
docker_container_prefix="project_course_airflow_aws_openweather"


# 🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
# AIRFLOW: Script to clean Airflow logs and restart containers

if [ "$modo_debug" = false ]; then
  echo "Iniciando Limpeza Airflow"
  if [ "$airflow" = true ]; then
    echo "🌀 Limpando logs do Airflow dentro dos containers..."
    docker exec ${docker_container_prefix}-airflow-scheduler-1 bash -c "rm -rf /opt/airflow/logs/*"
    docker exec ${docker_container_prefix}-airflow-webserver-1 bash -c "rm -rf /opt/airflow/logs/*"
    docker exec ${docker_container_prefix}-airflow-worker-1 bash -c "rm -rf /opt/airflow/logs/*"
    docker exec ${docker_container_prefix}-airflow-triggerer-1 bash -c "rm -rf /opt/airflow/logs/*"
    echo "✅ Logs internos do Airflow limpos."
  else 
    echo "airflow = false"
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  if [ "$reiniciar_containers" = true ]; then
    echo "🌀 Todos os logs limps. Reiniciando os containers..."
    docker restart ${docker_container_prefix}-airflow-scheduler-1 ${docker_container_prefix}-airflow-webserver-1 ${docker_container_prefix}-airflow-worker-1 ${docker_container_prefix}-airflow-triggerer-1
    echo "Containers restarted. Checking container status..."
    docker ps -a | grep ${docker_container_prefix} # Show container status
  else 
    echo "reiniciar_containers = false"
  fi
else 
  echo "debug true"
fi
# exit 1
# 🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰


echo "🧹 Iniciando limpeza total do Docker com permissões sudo..."

if [ "$modo_debug" = false ]; then
# 0. Derrubando serviços Docker Compose, se houver
  if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
    echo "📉 Executando 'docker compose down'..."
    if sudo docker compose down --volumes --remove-orphans; then
      echo "✅ docker compose down executado com sucesso."
    else
      echo "❌ Falha ao executar docker compose down." >&2
      exit 1
    fi
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 1. Parar todos os containers em execução
  echo "⛔ Parando todos os containers..."
  if containers=$(sudo docker ps -aq) && [ -n "$containers" ]; then
    if sudo docker stop $containers; then
      echo "✅ Containers parados."
    else
      echo "❌ Falha ao parar containers." >&2
      exit 1
    fi
  else
    echo "⚠️ Nenhum container para parar."
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 2. Remover todos os containers
  echo "🗑️ Removendo todos os containers..."
  if containers=$(sudo docker ps -aq) && [ -n "$containers" ]; then
    if sudo docker rm -f $containers; then
      echo "✅ Containers removidos."
    else
      echo "❌ Falha ao remover containers." >&2
      exit 1
    fi
  else
    echo "⚠️ Nenhum container para remover."
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 3. Remover todas as imagens
  echo "🖼️ Removendo todas as imagens..."
  if images=$(sudo docker images -aq) && [ -n "$images" ]; then
    if sudo docker rmi -f $images; then
      echo "✅ Imagens removidas."
    else
      echo "❌ Falha ao remover imagens." >&2
      exit 1
    fi
  else
    echo "⚠️ Nenhuma imagem para remover."
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 4. Remover todos os volumes
  echo "📦 Removendo todos os volumes..."
  if volumes=$(sudo docker volume ls -q) && [ -n "$volumes" ]; then
    if sudo docker volume rm -f $volumes; then
      echo "✅ Volumes removidos."
    else
      echo "❌ Falha ao remover volumes." >&2
      exit 1
    fi
  else
    echo "⚠️ Nenhum volume para remover."
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 5. Remover redes não utilizadas (exceto as padrão)
  echo "🔌 Removendo redes não utilizadas..."
  if sudo docker network prune -f; then
    echo "✅ Redes não utilizadas removidas."
  else
    echo "❌ Falha ao remover redes." >&2
    exit 1
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 6. Remover cache de build
  echo "🛠️ Removendo cache de build..."
  if sudo docker builder prune -af; then
    echo "✅ Cache de build removido."
  else
    echo "❌ Falha ao remover cache de build." >&2
    exit 1
  fi
else 
  echo "debug true"
fi

if [ "$modo_debug" = false ]; then
  # 7. Prune geral para garantir limpeza total
  echo "🧽 Limpando tudo com docker system prune..."
  if sudo docker system prune -af --volumes; then
    echo "✅ Prune geral concluído."
  else
    echo "❌ Falha no docker system prune." >&2
    exit 1
  fi
else 
  echo "debug true"
fi

# 🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
# VERIFICAÇÃO
echo "✅ Limpeza completa do Docker finalizada!"

echo -e "\n🔍 Estado atual do Docker após limpeza:\n"

echo "🧱 Containers existentes:"
sudo docker ps -a || echo "Nenhum container encontrado."

echo -e "\n🖼️ Imagens existentes:"
sudo docker images || echo "Nenhuma imagem encontrada."

echo -e "\n📦 Volumes existentes:"
sudo docker volume ls || echo "Nenhum volume encontrado."

echo -e "\n🛠️ Builds existentes:"
sudo docker builder ls || echo "Nenhum builder encontrado."

echo -e "\n✨ Fim da verificação."

# 🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
# Reiniciar Docker

if [ "$reiniciar_docker" = true ]; then
  echo "Reiniciando Docker"
  sudo systemctl restart docker
else 
  echo "reiniciar_docker = false"
fi
