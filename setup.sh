#!/bin/bash

echo "?? Instalando dependencias..."
apt update && apt install curl git nodejs npm nano -y

echo "?? Creando carpeta del bot VPNIA..."
mkdir -p /opt/vpnia-bot && cd /opt/vpnia-bot

echo "?? Creando archivo config.js..."
cat> config.js <<EOF
module.exports = {
  bienvenida: "?? ¡Hola! Soy VPNIA, tu asistente de redes seguras.",
  ayuda: "?? Comandos disponibles:\\n -!crearusuario\\n -!renovarusuario\\n -!infovpn\\n -!stats\\n -!scriptvpn\\n -!premium",
  crearUsuario: "✅ Usuario SSH creado correctamente.",
  renovarUsuario: "?? Usuario SSH renovado correctamente.",
  error: "❌ Hubo un problema. Inténtalo de nuevo.",
  linkScripts: "?? Descarga tus scripts aquí: https:                       
  infoVPN: "?? Tips para tu VPN:\\n- Usa cifrado fuerte\\n- Actualiza tu servidor\\n- No compartas tu acceso\\n- Cambia puertos por seguridad",
  premiumInfo: "?? ¿Quieres acceso premium por 30 días?\\nContáctame directamente: https://wa.me/5492634841144"
};
EOF

echo "?? Creando archivo index.js..."
cat> index.js <<EOF
const { Client} = require('whatsapp-web.js');
const config = require('./config');
const { exec} = require('child_process');
const client = new Client();

client.on('qr', qr => console.log('?? Escanea este QR para vincular VPNIA.'));
client.on('ready', () => console.log('✅ VPNIA está lista.'));
client.on('message', msg => {
  const texto = msg.body.toLowerCase();
  if (texto === '!hola') msg.reply(config.bienvenida);
  else if (texto === '!ayuda') msg.reply(config.ayuda);
  else if (texto === '!crearusuario') {
    exec('bash crearusuario.sh', (err, stdout, stderr) => {
      msg.reply(err? config.error: stdout);
    });
  } else if (texto === '!renovarusuario') {
    exec('bash renovarusuario.sh', (err, stdout, stderr) => {
      msg.reply(err? config.error: stdout);
    });
  } else if (texto === '!infovpn') {
    msg.reply(config.infoVPN);
  } else if (texto === '!stats') {
    exec('uptime && free -h && df -h', (err, stdout, stderr) => {
      msg.reply(err? config.error: stdout);
    });
  } else if (texto === '!scriptvpn') {
    msg.reply(config.linkScripts);
  } else if (texto === '!premium') {
    msg.reply(config.premiumInfo);
  }
});
client.initialize();
EOF

echo "?? Creando archivo crearusuario.sh..."
cat> crearusuario.sh <<EOF
#!/bin/bash
USER="vpnuser\$(date +%s)"
PASS="vpnpass"
useradd -m -s /bin/bash \$USER
echo "\$USER:\$PASS" | chpasswd
echo "?? Usuario SSH creado:"
echo "Usuario: \$USER"
echo "Contraseña: \$PASS"
EOF

echo "?? Creando archivo renovarusuario.sh..."
cat> renovarusuario.sh <<EOF
#!/bin/bash
USUARIO="vpnuser123"
usermod -e \$(date -d "+30 days" +"%Y-%m-%d") \$USUARIO
echo "?? Usuario renovado por 30 días más: \$USUARIO"
EOF

chmod +x crearusuario.sh renovarusuario.sh

echo "?? Inicializando proyecto Node.js..."
npm init -y> /dev/null
npm install whatsapp-web.js

echo "✅ Instalación completada. Puedes editar textos con:"
echo "nano /opt/vpnia-bot/config.js"
echo "▶️ Para iniciar el bot:"
echo "cd /opt/vpnia-bot && node index.js"

