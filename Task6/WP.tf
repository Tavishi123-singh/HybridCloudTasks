provider "kubernetes" {}

resource "kubernetes_service" "example" {
  metadata {
    name = "wp-service"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "frontend"
    }
  port {
    node_port   = 30000 
    port        = 80
    target_port = 80
  }
  type = "NodePort"
 }
}


resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = "wp-pvc"
    labels = {
      app = "wordpress"
      tier = "frontend"
    }
  }


  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
resource "kubernetes_deployment" "wp-dep" {
  metadata {
    name = "wp-dep"
    labels = {
      app = "wordpress"
      tier = "frontend"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "wordpress"
        tier = "frontend"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "frontend"
        }
      }
      spec {
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata.0.name
          }
        }
        container {
           image = "wordpress"
           name  = "wordpress-container"
           port {
             container_port = 80
           }
           volume_mount {
             name = "wordpress-persistent-storage"
             mount_path = "/var/www/html"
           }
        }
      }
    }
  }
}
