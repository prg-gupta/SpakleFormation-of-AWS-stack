SparkleFormation.new(:newstack) do
  _set('AWSTemplateFormatVersion', '2010-09-09')

parameters(:vpc_id) do
  type 'String'
  Default '10.80.0.0/16'
end

parameters(:private_subnet_id) do
  type 'String'
  Default '10.80.11.0/24'
end

parameters(:public_subnet_id) do
  type 'String'
  Default '10.80.21.0/24'
end


parameters(:ImageID) do
  type 'String'
  Default 'ami-48db9d28'
end

parameters(:InstanceType) do
  type 'String'
  Default 't2.small'
end

parameters(:AccessKey) do
  type 'String'
  Default 'plivo-test'
end

parameters(:RootDeviceSize) do
  type 'Number'
  Default '8'
end


resources do
  VPC do
    type 'AWS::EC2::VPC'
    properties do
      cidr_block   ref!(:vpc_id)
    end
  end

  PRISUBNET do
    type 'AWS::EC2::Subnet'
    properties do
      vpc_id ref!(:VPC)
      cidr_block   ref!(:private_subnet_id)
      availability_zone 'us-west-1a'
    end
  end 
  
  PUBSUBNET do
    type 'AWS::EC2::Subnet'
    properties do
      vpc_id ref!(:VPC)
      cidr_block   ref!(:public_subnet_id)
      availability_zone 'us-west-1a'
    end
  end
  
  InternetGateway do 
    type 'AWS::EC2::InternetGateway'
  end 
  
  AttachGateway do
    type 'AWS::EC2::VPCGatewayAttachment'
    properties do
      vpc_id ref!(:VPC)
      InternetGatewayId ref!(:InternetGateway)
    end
  end

  NATEIP do
    type 'AWS::EC2::EIP'
    properties do
      domain "vpc"
    end
   end
  NAT do
    type 'AWS::EC2::NatGateway'
    properties do
      allocationId  attr!(:NATEIP,'AllocationId')
      SubnetId  ref!(:PUBSUBNET)
    end 
  end 

  PublicRouteTable do 
    type 'AWS::EC2::RouteTable'
    properties do
      vpc_id ref!(:VPC)
    end
  end

 PrivateRouteTable do 
    type 'AWS::EC2::RouteTable'
    properties do
      vpc_id ref!(:VPC)
    end
  end

 PublicRoute do
    type 'AWS::EC2::Route'
    properties do
      RouteTableId ref!(:PublicRouteTable)
      DestinationCidrBlock '0.0.0.0/0'
      GatewayId ref!(:InternetGateway)
    end
  end 
 
  
 PrivateRoute do
    type 'AWS::EC2::Route'
    properties do
      RouteTableId ref!(:PrivateRouteTable)
      DestinationCidrBlock '0.0.0.0/0'
      NatGatewayId ref!(:NAT)
    end
  end

  PublicSubnetRouteTableAssociation do 
    type 'AWS::EC2::SubnetRouteTableAssociation'
    properties do
      SubnetId ref!(:PUBSUBNET)
      RouteTableId ref!(:PublicRouteTable)
    end
  end

  PrivateSubnetRouteTableAssociation do
    type 'AWS::EC2::SubnetRouteTableAssociation'
    properties do
      SubnetId ref!(:PRISUBNET)
      RouteTableId ref!(:PrivateRouteTable)
    end
  end

  PlivoTestSG do
    type 'AWS::EC2::SecurityGroup'
    properties do 
      GroupDescription 'PlivoTESTSG'
      vpc_id ref!(:VPC)
    end
  end

 SG_ingress do
   type 'AWS::EC2::SecurityGroupIngress'
   properties do
        group_id ref!(:PlivoTestSG)
        ip_protocol 'tcp'
        from_port 22
        to_port 22
        cidr_ip '0.0.0.0/0'
      end
   end

   SG_ingress do
   type 'AWS::EC2::SecurityGroupIngress'
   properties do
        group_id ref!(:PlivoTestSG)
        ip_protocol '-1'
        from_port 1
        to_port 65535
        cidr_ip '0.0.0.0/0'
      end
   end

  PublicInstance do
  type 'AWS::EC2::Instance'
  properties do 
    InstanceType ref!(:InstanceType)
    ImageId ref!(:ImageID)
    SubnetId ref!(:PUBSUBNET)
    KeyName ref!(:AccessKey)
    SecurityGroupIds [ref!(:PlivoTestSG)]
  end
 end

  PublicInstanceEIP do
    type 'AWS::EC2::EIP'
    properties do 
      Domain vpc
      InstanceId ref!(:PublicInstance)
    end
  end

PrivateInstance do
  type 'AWS::EC2::Instance'
  properties do 
    InstanceType ref!(:InstanceType)
    ImageId ref!(:ImageID)
    SubnetId ref!(:PRISUBNET)
    KeyName ref!(:AccessKey)
    SecurityGroupIds [ref!(:PlivoTestSG)]
  end
 end

end 


outputs do
  vpc_id do
    description 'VPC ID is :'
    value ref!(:VPC)
  end
  
  pub_sub_id do
    description 'Public subnet ID is :'
    value ref!(:PUBSUBNET)
  end
  
  pub_instance_id do 
     value ref!(:PublicInstance)
  end


  pri_sub_id do
    description 'Private subnet ID is :'
    value ref!(:PRISUBNET)
  end
 
   pri_instance_id do
     value ref!(:PrivateInstance)
  end

end

end
