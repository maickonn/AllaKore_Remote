
# Discontinuation Notice

Attention, this project has been discontinued and is thus being archived. However, there are some highly promising forks that are quite advanced and feature-rich. We recommend checking out [Aegys](https://github.com/OpenSourceCommunityBrasil/Aegys-Acesso-Remoto), which is actively developed by the Open Source Community Brazil.

# AllaKore Remote

This source has created by Maickonn Richard & Gabriel Stilben.

AllaKore Remote is a Remote Access software open source written in Delphi Seattle.

I apologize for my English because it is not my native language. :D

----
**All components used are native to Delphi itself.**

<strong>There are some observations to be taken before opening the project:</strong>

* The software requires a central server, I recommend host it on a server inside your country, so there is a low latency.
* Like any BETA project, this is subject to bugs that will be corrected over time. I count on the cooperation of all.
* If they can solve any problem, just send the solution that it will be posted.
* The function of the server is to route all data traffic, delivering each packet to the correct user. The server forwards the packets as soon as they are received to gain performance.
* On the Client project, the unit has two Form_Main constant calls "Host" and "Port". In the constant "Host" you must enter the DNS or IP address of your server. In the constant "Port" you should enter the port that was chosen in the constant of the "Server".



<strong>AllaKore Remote has the following functions:</strong>

* Connection ID and Password.
* Remote access with RFB algorithm (Send only what has changed on the screen).
* Data Compression (zLib).
* Sharer files.
* Chat.
* UAC Interaction.

---

<strong>DEMO</strong>
![UAC Interaction](Assets/demo.gif)

<strong>UAC Interaction DEMO</strong>
![UAC Interaction](Assets/uac_interaction.gif)
