resource "aws_iam_openid_connect_provider" "demo" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.thumb.certificates[*].sha1_fingerprint
  url             = aws_eks_cluster.demo.identity.0.oidc.0.issuer
}
data "tls_certificate" "thumb" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "aws-ebs-csi-driver-trust-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    /* condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    } */
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.demo.arn}"]
      type        = "Federated"
    }
  }
}

/* data "aws_iam_policy_document" "aws_load_balancer_controller_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.demo.arn}"]
      type        = "Federated"
    }
  }
} */

resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  assume_role_policy = data.aws_iam_policy_document.aws-ebs-csi-driver-trust-policy.json
  name               = "AmazonEKS_EBS_CSI_DriverRole"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
}

/* resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_policy.json
  name               = "aws-load-balancer-controller"
} */
/* resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("./AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
} */
/* resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
} */
/* output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
} */