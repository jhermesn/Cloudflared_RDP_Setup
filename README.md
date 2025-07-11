# Cloudflared RDP Setup
Este projeto automatiza a configuração de um túnel RDP (Remote Desktop Protocol) seguro usando Cloudflared. Ele permite acessar um servidor RDP através de um túnel Cloudflare, adicionando uma camada extra de segurança e permitindo o acesso remoto sem expor diretamente a porta RDP.

## Pré-requisitos
*   Windows
*   Acesso à internet
*   Cloudflared instalado

## Como usar
1.  **Baixe o script:** Faça o download do arquivo `app.bat` para seu computador.
2.  **Execute o script:** Execute `app.bat` como administrador.
3.  **Siga as instruções:** O script irá guiá-lo através do processo de configuração, solicitando as seguintes informações:
    *   **Hostname:** O hostname para a conexão RDP. Se não for fornecido, o padrão `IP.DA.MAQUINA` será usado.
    *   **Porta:** A porta que você deseja usar para o túnel RDP. Se não for fornecida, a porta padrão `3390` será usada.

## Explicação do Script
O script `app.bat` realiza as seguintes ações:

1.  **Configurações Iniciais:**
    *   Define a página de código para UTF-8 para garantir a exibição correta de caracteres.
    *   Habilita a expansão atrasada de variáveis.
2.  **Solicita Informações do Usuário:**
    *   Solicita o hostname e a porta para a conexão RDP.
    *   Se o Cloudflared não estiver instalado, solicita a versão a ser instalada.
3.  **Cria os Processos:**
    *   Inicia o Cloudflared para criar um túnel RDP para o hostname e a porta especificados.
    *   Inicia o cliente MSTSC (Remote Desktop Connection) para conectar-se ao túnel RDP.
4.  **Monitora os Processos:**
    *   Monitora os processos Cloudflared e MSTSC.
    *   Se um dos processos for encerrado, o outro também será encerrado.
5.  **Finaliza:**
    *   Encerra o script.

## Notas
*   Este script foi projetado para simplificar a configuração de um túnel RDP com Cloudflared.
*   Este projeto está sob a [licença MIT](LICENSE).