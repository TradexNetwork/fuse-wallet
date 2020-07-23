import 'package:flutter/material.dart';
import 'package:seedbed/models/pro/token.dart';
import 'package:seedbed/models/token.dart' as token;
import 'package:seedbed/models/plugins/fee_base.dart';

enum SendType {
  CONTACT,
  BUSINESS,
  QR_ADDRESS,
  FUSE_ADDRESS,
  PASTED_ADDRESS,
  ETHEREUM_ADDRESS
}

class SendAmountArguments {
  String name;
  String phoneNumber;
  String accountAddress;
  num amount;
  ImageProvider avatar;
  SendType sendType;
  bool sendToCashMode = false;
  bool isProMode = false;
  Token erc20Token;
  token.Token tokenToSend;
  FeePlugin feePlugin;
  final bool isConvert;

  SendAmountArguments(
      {this.sendToCashMode = false,
      this.sendType,
      this.isConvert = false,
      this.isProMode = false,
      this.name,
      this.phoneNumber,
      this.erc20Token,
      this.accountAddress,
      this.amount,
      this.feePlugin,
      this.avatar});
}
