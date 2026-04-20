namespace :vapid do
  desc "Gera um par de chaves VAPID para Web Push"
  task generate: :environment do
    require "web-push"
    keys = WebPush.generate_key
    puts ""
    puts "=========================================="
    puts " Chaves VAPID geradas"
    puts "=========================================="
    puts "VAPID_PUBLIC_KEY=#{keys.public_key}"
    puts "VAPID_PRIVATE_KEY=#{keys.private_key}"
    puts "VAPID_SUBJECT=mailto:seu-email@exemplo.com"
    puts ""
    puts "Adicione essas variaveis no Railway (servico web)."
    puts "Use a mesma chave publica em VAPID_PUBLIC_KEY localmente para testes."
    puts ""
  end

  desc "Gera um token aleatorio para CRON_TOKEN"
  task token: :environment do
    require "securerandom"
    puts ""
    puts "CRON_TOKEN=#{SecureRandom.hex(32)}"
    puts ""
  end
end
