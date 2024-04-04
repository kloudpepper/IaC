##################
### EFS Module ###
##################

resource "aws_efs_file_system" "EFSFileSystem" {
  creation_token   = "EFSFileSystem"
  performance_mode = "generalPurpose"
  encrypted        = true
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  tags = {
    Name = "${var.environmentName}-EFS"
  }
}

resource "aws_efs_mount_target" "EFSMountTarget1" {
  file_system_id  = aws_efs_file_system.EFSFileSystem.id
  security_groups = [var.EFSSecurityGroup_id]
  subnet_id       = var.PrivateSubnet1_id
}

resource "aws_efs_mount_target" "EFSMountTarget2" {
  file_system_id  = aws_efs_file_system.EFSFileSystem.id
  security_groups = [var.EFSSecurityGroup_id]
  subnet_id       = var.PrivateSubnet2_id
}

resource "aws_efs_access_point" "import-request" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/opt"
  }
  tags = {
    Name = "request"
  }
}

resource "aws_efs_access_point" "import-response" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/opt/tocfee"
  }
  tags = {
    Name = "import"
  }
}

resource "aws_efs_access_point" "import-error" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/opt/error"
  }
  tags = {
    Name = "error"
  }
}

resource "aws_efs_access_point" "dw-export" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/s3"
  }
  tags = {
    Name = "export"
  }
}

resource "aws_efs_access_point" "dfe" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/t23"
  }
  tags = {
    Name = "dfe"
  }
}

resource "aws_efs_access_point" "udexternal" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/t23/uuexternal"
  }
  tags = {
    Name = "udexternal"
  }
}

resource "aws_efs_access_point" "cfrextract" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/${var.environmentName}/CF"
  }
  tags = {
    Name = "cfrextract"
  }
}

resource "aws_efs_access_point" "TAFJ_log" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/log"
  }
  tags = {
    Name = "log"
  }
}

resource "aws_efs_access_point" "TAFJ_logT24" {
  file_system_id = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/logT23"
  }
  tags = {
    Name = "logT23"
  }
}