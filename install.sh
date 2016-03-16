#!/bin/bash

SERVICE_FILE="n42agent.sh"
DAEMON_FILE="Agent.py"
SYSTEM_CHECK="SystemCheck.py"
NETWORK_CHECK="NetworkCheck.py"

echo "--- Download n42agent init script ---"
wget -q -O "$SERVICE_FILE" 'https://gist.githubusercontent.com/kirann42/7e5a557680fdc672b187/raw/27acb36eddba56bca7ddcefe322f56712e813613/n42agent.sh'
chmod +x "$SERVICE_FILE"
echo ""

echo "--- Download agent ---"
wget -q -O "$DAEMON_FILE" 'https://gist.githubusercontent.com/kirann42/6073d9efc2b4fdca4fce/raw/ed7bbf5e996cc5c1f216e718bbb4991681c58a8f/Agent.py'
chmod +x "$DAEMON_FILE"
echo ""

echo "--- Download checks ---"
wget -q -O "$SYSTEM_CHECK" 'https://gist.githubusercontent.com/kirann42/7c0c92af086c6bccce2f/raw/6afdb7dc527709ca94c12816a7dabbd7325f8bdb/SystemCheck.py'
chmod +x "$SYSTEM_CHECK"
wget -q -O "$NETWORK_CHECK" 'https://gist.githubusercontent.com/kirann42/90ff4553bce0aa500485/raw/f6671b376f69320cc4f049d2b25f2b0bd614b356/NetworkCheck.py'
chmod +x "$NETWORK_CHECK"
echo ""

#echo "--- Customize ---"
#echo "I'll now ask you some information to customize script"
#echo "Press Ctrl+C anytime to abort."
#echo "Empty values are not accepted."
#echo ""

prompt_token() {
  local VAL=""
  while [ "$VAL" = "" ]; do
    echo -n "${2:-$1} : "
    read VAL
    if [ "$VAL" = "" ]; then
      echo "Please provide a value"
    fi
  done
  VAL=$(printf '%q' "$VAL")
  eval $1=$VAL
  sed -i "s/<$1>/$(printf '%q' "$VAL")/g" $SERVICE_FILE
}

#prompt_token 'NAME'        'Service name'
#if [ -f "/etc/init.d/$NAME" ]; then
#  echo "Error: service '$NAME' already exists"
#  exit 1
#fi

#prompt_token 'DESCRIPTION' ' Description'
#prompt_token 'COMMAND'     '     Command'
#prompt_token 'USERNAME'    '        User'
#if ! id -u "$USERNAME" &> /dev/null; then
#  echo "Error: user '$USERNAME' not found"
#  exit 1
#fi

NAME="n42agent"

echo ""

echo "--- Installation ---"
if [ ! -w /etc/init.d ]; then
  echo "You don't gave me enough permissions to install service myself."
  echo "That's smart, always be really cautious with third-party shell scripts!"
  echo "You should now type those commands as superuser to install and run your service:"
  echo ""
  echo "   mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  echo "   touch \"/var/log/$NAME.log\" && chown \"$USERNAME\" \"/var/log/$NAME.log\""
  echo "   update-rc.d \"$NAME\" defaults"
  echo "   service \"$NAME\" start"
else
  echo "[----------Installation started ---------------]"
  echo ""
  echo "[------------Agent Cleanup Started(Removing Old Agents for fresh installation)-----------]"   
  if service --status-all |& grep -Fq 'n42agent';
  then 
       service n42agent stop
       echo "Please type yes as the answer as we are removing old Agents"   
       service n42agent uninstall    
  fi	
  if [ -f /opt/agents/n42/SystemCheck.py ];
  then 
      rm -r /opt/agents/n42/
      rm /etc/init.d/n42agent        
  fi
  echo "[------------Agent Cleanup Ended-----------]"   
  echo ""
  if [[ ! -e /opt/agents/n42/ ]]; 
  then
       #echo "creating agents directory for installing n42agent"	
       mkdir -p /opt/agents/n42/
       if [ $? -ne 0 ];
       then
            echo "could not create directory : /opt/agents/n42/"
            exit 1
       fi
  fi  
  echo "[------------Copying the Agents Started -----------]"   
  #echo "mv \"$DAEMON_FILE\" \"/opt/agents/n42\""
  mv -v "$DAEMON_FILE" "/opt/agents/n42/"
  mv -v "$SYSTEM_CHECK" "/opt/agents/n42/"
  mv -v "$NETWORK_CHECK" "/opt/agents/n42/"
  #echo "mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  mv -v "$SERVICE_FILE" "/etc/init.d/$NAME"
  echo "[------------Copying the Agents Ended --------------]"   
  #echo "touch \"/var/log/myloop.log\""
  #touch "/var/log/$NAME.log" && chown "$USERNAME" "/var/log/$NAME.log"
  #echo "3. update-rc.d \"$NAME\" defaults"
  #update-rc.d "$NAME" defaults
  echo ""
  #echo "service \"$NAME\" start"
  sudo service "$NAME" start
  echo ""
  echo "!!!!!!! Installation succesful ! Have that Mc Donalds IceCream !!!!!!!!!!."
fi
echo ""
echo ""
echo ""
echo "[--------------Agent usage Instructions------------------]"
echo "To start the agent : service n42agent start"
echo "To stop the agent : service n42agent stop"
echo "To uninstall the agent : service n42agent uninstall"
echo "[--------------------------------------------------------]"
#echo "---Uninstall instructions ---"
#echo "The service can uninstall itself:"
#echo "    service \"$NAME\" uninstall"
#echo "It will simply run update-rc.d -f \"$NAME\" remove && rm -f \"/etc/init.d/$NAME\""
#echo ""
#echo "--- Terminated ---"