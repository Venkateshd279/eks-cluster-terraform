"""
EKS Infrastructure Architecture Diagram Generator
This script creates a visual architecture diagram in PNG/JPG format
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

def create_architecture_diagram():
    # Create figure and axis
    fig, ax = plt.subplots(1, 1, figsize=(20, 16))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Colors
    colors = {
        'internet': '#FF6B6B',
        'public': '#4ECDC4',
        'private': '#45B7D1',
        'eks': '#96CEB4',
        'aws_services': '#FECA57',
        'customer': '#FF9FF3',
        'admin': '#54A0FF'
    }
    
    # Title
    ax.text(50, 95, 'EKS Infrastructure Architecture', 
            fontsize=24, fontweight='bold', ha='center')
    ax.text(50, 92, 'Production-Grade Multi-Tier Application', 
            fontsize=16, ha='center', style='italic')
    
    # Internet/Customer Layer
    internet_box = FancyBboxPatch((5, 85), 90, 6, 
                                  boxstyle="round,pad=0.3", 
                                  facecolor=colors['customer'], 
                                  edgecolor='black', linewidth=2)
    ax.add_patch(internet_box)
    ax.text(50, 88, '👥 CUSTOMERS (Internet)', fontsize=14, fontweight='bold', ha='center')
    ax.text(20, 86.5, '🌐 Web Browser', fontsize=10, ha='center')
    ax.text(50, 86.5, '📱 Mobile Apps', fontsize=10, ha='center')
    ax.text(80, 86.5, '🔗 API Clients', fontsize=10, ha='center')
    
    # DNS/Route 53
    dns_box = FancyBboxPatch((35, 78), 30, 4, 
                             boxstyle="round,pad=0.2", 
                             facecolor='#FFE4E1', 
                             edgecolor='black', linewidth=1)
    ax.add_patch(dns_box)
    ax.text(50, 80, 'Route 53 DNS', fontsize=12, fontweight='bold', ha='center')
    ax.text(50, 79, 'your-app.com', fontsize=10, ha='center')
    
    # VPC Container
    vpc_box = FancyBboxPatch((2, 2), 96, 72, 
                             boxstyle="round,pad=0.5", 
                             facecolor='#F8F9FA', 
                             edgecolor='black', linewidth=3)
    ax.add_patch(vpc_box)
    ax.text(8, 70, 'AWS VPC (10.0.0.0/16)', fontsize=16, fontweight='bold')
    
    # Public Subnet
    public_subnet = FancyBboxPatch((5, 45), 90, 25, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor=colors['public'], 
                                   alpha=0.3, edgecolor='black', linewidth=2)
    ax.add_patch(public_subnet)
    ax.text(8, 67, 'PUBLIC SUBNETS (10.0.1.0/24, 10.0.2.0/24)', 
            fontsize=14, fontweight='bold')
    
    # Application Load Balancer
    alb_box = FancyBboxPatch((20, 60), 60, 6, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['internet'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(alb_box)
    ax.text(50, 63, '🔄 Application Load Balancer (ALB)', 
            fontsize=12, fontweight='bold', ha='center', color='white')
    ax.text(50, 61.5, 'my-eks-cluster-web-alb-1309538953...', 
            fontsize=9, ha='center', color='white')
    
    # Web Servers
    web1_box = FancyBboxPatch((10, 50), 18, 8, 
                              boxstyle="round,pad=0.2", 
                              facecolor='white', 
                              edgecolor='black', linewidth=1.5)
    ax.add_patch(web1_box)
    ax.text(19, 56, '🖥️ Web Server 1', fontsize=11, fontweight='bold', ha='center')
    ax.text(19, 54.5, '13.232.85.18', fontsize=9, ha='center')
    ax.text(19, 53, 'Frontend/Nginx', fontsize=9, ha='center')
    ax.text(19, 51.5, 'AZ: ap-south-1a', fontsize=8, ha='center', style='italic')
    
    web2_box = FancyBboxPatch((72, 50), 18, 8, 
                              boxstyle="round,pad=0.2", 
                              facecolor='white', 
                              edgecolor='black', linewidth=1.5)
    ax.add_patch(web2_box)
    ax.text(81, 56, '🖥️ Web Server 2', fontsize=11, fontweight='bold', ha='center')
    ax.text(81, 54.5, '13.232.101.109', fontsize=9, ha='center')
    ax.text(81, 53, 'Frontend/Nginx', fontsize=9, ha='center')
    ax.text(81, 51.5, 'AZ: ap-south-1b', fontsize=8, ha='center', style='italic')
    
    # Jenkins Server
    jenkins_box = FancyBboxPatch((45, 50), 18, 8, 
                                 boxstyle="round,pad=0.2", 
                                 facecolor=colors['admin'], 
                                 edgecolor='black', linewidth=1.5)
    ax.add_patch(jenkins_box)
    ax.text(54, 56, '🔧 Jenkins Server', fontsize=11, fontweight='bold', ha='center', color='white')
    ax.text(54, 54.5, '13.204.60.118:8080', fontsize=9, ha='center', color='white')
    ax.text(54, 53, 'CI/CD Pipeline', fontsize=9, ha='center', color='white')
    ax.text(54, 51.5, 'Ubuntu 22.04', fontsize=8, ha='center', style='italic', color='white')
    
    # Private Subnet
    private_subnet = FancyBboxPatch((5, 5), 90, 35, 
                                    boxstyle="round,pad=0.3", 
                                    facecolor=colors['private'], 
                                    alpha=0.3, edgecolor='black', linewidth=2)
    ax.add_patch(private_subnet)
    ax.text(8, 37, 'PRIVATE SUBNETS (10.0.10.0/24, 10.0.11.0/24)', 
            fontsize=14, fontweight='bold')
    
    # App Servers
    app1_box = FancyBboxPatch((10, 28), 18, 8, 
                              boxstyle="round,pad=0.2", 
                              facecolor='white', 
                              edgecolor='black', linewidth=1.5)
    ax.add_patch(app1_box)
    ax.text(19, 34, '⚙️ App Server 1', fontsize=11, fontweight='bold', ha='center')
    ax.text(19, 32.5, '10.0.10.176', fontsize=9, ha='center')
    ax.text(19, 31, 'Business Logic', fontsize=9, ha='center')
    ax.text(19, 29.5, 'AZ: ap-south-1a', fontsize=8, ha='center', style='italic')
    
    app2_box = FancyBboxPatch((72, 28), 18, 8, 
                              boxstyle="round,pad=0.2", 
                              facecolor='white', 
                              edgecolor='black', linewidth=1.5)
    ax.add_patch(app2_box)
    ax.text(81, 34, '⚙️ App Server 2', fontsize=11, fontweight='bold', ha='center')
    ax.text(81, 32.5, '10.0.11.29', fontsize=9, ha='center')
    ax.text(81, 31, 'Business Logic', fontsize=9, ha='center')
    ax.text(81, 29.5, 'AZ: ap-south-1b', fontsize=8, ha='center', style='italic')
    
    # EKS Cluster
    eks_cluster = FancyBboxPatch((30, 8), 40, 18, 
                                 boxstyle="round,pad=0.3", 
                                 facecolor=colors['eks'], 
                                 alpha=0.4, edgecolor='black', linewidth=2)
    ax.add_patch(eks_cluster)
    ax.text(50, 24, '☸️ EKS CLUSTER', fontsize=14, fontweight='bold', ha='center')
    ax.text(50, 22, 'my-eks-cluster (v1.32)', fontsize=12, ha='center')
    
    # EKS Worker Nodes
    worker1_box = FancyBboxPatch((32, 15), 14, 6, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='white', 
                                 edgecolor='black', linewidth=1)
    ax.add_patch(worker1_box)
    ax.text(39, 18.5, 'Worker Node 1', fontsize=9, fontweight='bold', ha='center')
    ax.text(39, 17, '10.0.10.86', fontsize=8, ha='center')
    ax.text(39, 15.5, 't2.medium', fontsize=8, ha='center')
    
    worker2_box = FancyBboxPatch((54, 15), 14, 6, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='white', 
                                 edgecolor='black', linewidth=1)
    ax.add_patch(worker2_box)
    ax.text(61, 18.5, 'Worker Node 2', fontsize=9, fontweight='bold', ha='center')
    ax.text(61, 17, '10.0.11.158', fontsize=8, ha='center')
    ax.text(61, 15.5, 't2.medium', fontsize=8, ha='center')
    
    # Kubernetes Pods
    ax.text(50, 13, '📦 Pods: sample-web-app (3 replicas)', 
            fontsize=10, ha='center', fontweight='bold')
    ax.text(50, 11.5, '🔗 Service: ClusterIP 172.20.62.48:80', 
            fontsize=9, ha='center')
    ax.text(50, 10, '🌐 Ingress: ALB Controller Ready', 
            fontsize=9, ha='center')
    
    # Traffic Flow Arrows
    # Customer to DNS
    arrow1 = ConnectionPatch((50, 85), (50, 82), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='red', linewidth=3)
    ax.add_patch(arrow1)
    
    # DNS to ALB
    arrow2 = ConnectionPatch((50, 78), (50, 66), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='red', linewidth=3)
    ax.add_patch(arrow2)
    
    # ALB to Web Servers
    arrow3 = ConnectionPatch((40, 60), (25, 58), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='blue', linewidth=2)
    ax.add_patch(arrow3)
    
    arrow4 = ConnectionPatch((60, 60), (75, 58), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='blue', linewidth=2)
    ax.add_patch(arrow4)
    
    # Web Servers to App Servers
    arrow5 = ConnectionPatch((19, 50), (19, 36), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='green', linewidth=2)
    ax.add_patch(arrow5)
    
    arrow6 = ConnectionPatch((81, 50), (81, 36), "data", "data",
                            arrowstyle="->", shrinkA=5, shrinkB=5,
                            color='green', linewidth=2)
    ax.add_patch(arrow6)
    
    # Legend
    legend_elements = [
        patches.Patch(color=colors['customer'], label='Customer Layer'),
        patches.Patch(color=colors['public'], alpha=0.3, label='Public Subnet'),
        patches.Patch(color=colors['private'], alpha=0.3, label='Private Subnet'),
        patches.Patch(color=colors['eks'], alpha=0.4, label='EKS Cluster'),
        patches.Patch(color=colors['admin'], label='Admin/CI/CD'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(0.98, 0.85))
    
    # Add URLs and Access Information
    info_text = """
    🌐 Customer URL: http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
    🔧 Jenkins: http://13.204.60.118:8080
    ☸️ EKS App: http://localhost:8080 (port-forward)
    
    🛡️ Security: App servers in private subnets, accessed via web servers only
    📊 High Availability: Multi-AZ deployment with load balancing
    🔄 CI/CD: GitHub → Jenkins → EKS automated deployment
    """
    
    ax.text(2, 2, info_text, fontsize=9, verticalalignment='bottom',
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    return fig

def save_diagram():
    """Generate and save the architecture diagram"""
    print("🎨 Generating EKS Architecture Diagram...")
    
    fig = create_architecture_diagram()
    
    # Save as PNG (high resolution)
    png_filename = "EKS_Architecture_Diagram.png"
    fig.savefig(png_filename, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    print(f"✅ PNG diagram saved as: {png_filename}")
    
    # Save as JPG (compressed)
    jpg_filename = "EKS_Architecture_Diagram.jpg"
    fig.savefig(jpg_filename, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none', format='jpg')
    print(f"✅ JPG diagram saved as: {jpg_filename}")
    
    # Save as PDF (vector format)
    pdf_filename = "EKS_Architecture_Diagram.pdf"
    fig.savefig(pdf_filename, bbox_inches='tight', 
                facecolor='white', edgecolor='none', format='pdf')
    print(f"✅ PDF diagram saved as: {pdf_filename}")
    
    print("\n🎯 Diagram files created successfully!")
    print("📁 Check your current directory for the files:")
    print(f"   - {png_filename} (High-res PNG)")
    print(f"   - {jpg_filename} (Compressed JPG)")  
    print(f"   - {pdf_filename} (Vector PDF)")
    
    # Display the diagram
    plt.show()

if __name__ == "__main__":
    save_diagram()
