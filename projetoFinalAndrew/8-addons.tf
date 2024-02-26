

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.demo.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.demo.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name             = aws_eks_cluster.demo.name
  addon_name               = "aws-ebs-csi-driver"
  depends_on               = [aws_eks_node_group.private-nodes]
  service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.demo.name
  addon_name   = "coredns"
  depends_on   = [aws_eks_node_group.private-nodes]
}