# Linux Linux Virtual Machine (VM) with Load Balancer Project

This project demonstrates how to set up a Linux Virtual Machine (VM) in Microsoft Azure, with a load balancer to distribute incoming traffic across multiple instances for high availability and reliability using Terraform and bash scripts to automate the deployment and configuration process.

The solution provisions a complete networking foundation for a multi-tier application, with dedicated networking segments for web, application, database, and management workloads, ensuring proper isolation and security controls between them. The currently deployed workload consists of multiple linux web serves running Apache HTTP Server behind and Azure Load Balancer, allowing incoming requests to be distributed across heathy backend instances.

The architecture also separates inbound and outbound connectivity: Public application traffic is handled through the load balancer, while outbound internet access from the web tier is provided through an Azure NAT Gateway. Administrative access to the private virtual machines is supported through Azure Bastion and a dedicated Bastion Host instance for secure management, allowing the servers to remain isolated from direct public exposure.

Overall, the project demonstrates how Terraform can be used to build a reusable Azure infrastructure that combines networking, compute, load balancing, secure administration, outbound connectivity, and basic high-availability concepts.

# Architecture solution

In this section we provide a visual representation of the architecture solution, illustrating the various components and their interactions within the Azure environment. The first diagram is done with Mermaid and the second diagram is done using Azure Architecture icons.

**Virtual Network:** `10.0.0.0/16`

| Network Segment        | CIDR Block    | Purpose                                          |
| ---------------------- | ------------- | ------------------------------------------------ |
| **Web Subnet**         | `10.0.1.0/24` | Hosts the public-facing web virtual machines     |
| **Application Subnet** | `10.0.2.0/24` | Reserved for application-tier workloads          |
| **Database Subnet**    | `10.0.3.0/24` | Reserved for database services                   |
| **Management Subnet**  | `10.0.4.0/24` | Used for administrative and management workloads |
| **AzureBastionSubnet** | `10.0.5.0/27` | Dedicated subnet required by Azure Bastion       |

```mermaid
flowchart TB
    Internet((Internet))

    LBPublicIP["Public IP<br/>fin-dev-lbpublicip"]
    LoadBalancer["Azure Standard Load Balancer<br/>fin-dev-web-lb"]

    VNet["Azure Virtual Network<br/>fin-dev-vnet-default<br/>10.0.0.0/16"]

    WebSubnet["Web subnet<br/>fin-dev-vnet-default-websubnet<br/>10.0.1.0/24"]
    AppSubnet["Application subnet<br/>fin-dev-vnet-default-appsubnet<br/>10.0.2.0/24"]
    DBSubnet["Database subnet<br/>fin-dev-vnet-default-dbsubnet<br/>10.0.3.0/24"]
    MgmtSubnet["Management subnet<br/>fin-dev-vnet-default-bastionsubnet<br/>10.0.4.0/24"]
    BastionSubnet["AzureBastionSubnet<br/>10.0.5.0/27"]

    VM1["Ubuntu Web VM 1<br/>fin-dev-web-linuxvm-vm1<br/>Standard_DS1_v2"]
    VM2["Ubuntu Web VM 2<br/>fin-dev-web-linuxvm-vm2<br/>Standard_DS1_v2"]

    NAT["NAT Gateway<br/>fin-dev-web-natgw"]
    NATPublicIP["Public IP<br/>fin-dev-natgw-publicip"]

    Bastion["Azure Bastion<br/>fin-dev-bastion-service"]
    BastionPublicIP["Public IP<br/>fin-dev-bastion-service-public-ip"]

    AdminVM["Optional Management VM<br/>fin-dev-bastion-host-linuxvm"]
    AdminPublicIP["Public IP<br/>fin-dev-bastion-public-ip"]

    Internet --> LBPublicIP
    LBPublicIP --> LoadBalancer
    LoadBalancer --> VM1
    LoadBalancer --> VM2

    VNet --> WebSubnet
    VNet --> AppSubnet
    VNet --> DBSubnet
    VNet --> MgmtSubnet
    VNet --> BastionSubnet

    WebSubnet --> VM1
    WebSubnet --> VM2
    WebSubnet --> NAT
    NAT --> NATPublicIP
    NATPublicIP --> Internet

    BastionPublicIP --> Bastion
    Bastion --> BastionSubnet
    Bastion -. Administrative access .-> VM1
    Bastion -. Administrative access .-> VM2

    AdminPublicIP --> AdminVM
    AdminVM --> MgmtSubnet
```

# Data Flow

In this section, we describe the data flow within the architecture, detailing how requests and responses traverse through the various components.

```mermaid
sequenceDiagram
    participant User as Internet User
    participant LB as Azure Standard Load Balancer
    participant VM as Web VM 1 or Web VM 2
    participant Admin as Administrator
    participant Bastion as Azure Bastion
    participant NAT as NAT Gateway
    participant External as External Internet Service

    User->>LB: HTTP request to public IP:80
    LB->>LB: TCP health probe on port 80
    LB->>VM: Forward request to port 80
    VM->>User: Return Apache web response

    Admin->>Bastion: Connect through Azure portal
    Bastion->>VM: SSH connection over private networking
    VM->>Bastion: Administrative response

    VM->>NAT: Outbound internet request
    NAT->>External: Translate private source address
    External-->>NAT: Return response
    NAT-->>VM: Return translated response
```

1. A user sends an HTTP request to the public IP address attached to the Azure Load Balancer.
2. The request reaches the frontend configuration named web-lb-publicip-1.
3. The Standard Load Balancer checks backend availability using the TCP health probe named tcp-probe.
4. The health probe tests port 80 on the backend web VMs.
5. If a VM is healthy, the load balancer forwards the request to port 80.
6. The request is sent to one of the following backend instances:
   - `fin-dev-web-linuxvm-vm1`
   - `fin-dev-web-linuxvm-vm2`
7. Apache returns the static web content installed by `ubuntu-webvm-script.sh`.
8. The response travels back through the load balancer to the client.
