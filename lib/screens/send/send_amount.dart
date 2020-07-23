import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:seedbed/generated/i18n.dart';
import 'package:seedbed/models/token.dart';
import 'package:seedbed/models/views/send_amount.dart';
import 'package:seedbed/screens/send/send_amount_arguments.dart';
import 'package:seedbed/screens/send/send_review.dart';
import 'package:seedbed/utils/format.dart';
import 'package:seedbed/widgets/main_scaffold.dart';
import 'package:seedbed/widgets/primary_button.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';
import 'package:seedbed/models/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';

class SendAmountScreen extends StatefulWidget {
  final SendAmountArguments pageArgs;
  SendAmountScreen({this.pageArgs});
  @override
  _SendAmountScreenState createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen>
    with SingleTickerProviderStateMixin {
  String amountText = "0";
  AnimationController controller;
  Animation<Offset> offset;
  bool isPreloading = false;
  Token dropdownValue;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<dynamic>> buildDropdownMenuItems(List<Token> options) {
    return options.map((Token token) {
      print('${token.name} ${token.address}');
      return DropdownMenuItem(
        value: token,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // CachedNetworkImage(
              //   width: 25,
              //   height: 25,
              //   imageUrl: getIPFSImageUrl(community.metadata.image),
              //   placeholder: (context, url) => CircularProgressIndicator(),
              //   errorWidget: (context, url, error) => Image(
              //     image: NetworkImage(
              //       'https://cdn3.iconfinder.com/data/icons/abstract-1/512/no_image-512.png',
              //     ),
              //     width: 25,
              //     height: 25,
              //   ),
              // ),
              SizedBox(
                width: 5,
              ),
              Text(token.symbol,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Segment.screen(screenName: '/send-amount-screen');
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, 2.0), end: Offset.zero).animate(
        new CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad));
  }

  @override
  Widget build(BuildContext context) {
    final SendAmountArguments args = this.widget.pageArgs;
    String title =
        "${I18n.of(context).send_to} ${args.name != null ? args.name : formatAddress(args.accountAddress)}";
    return new StoreConnector<AppState, SendAmountViewModel>(
      converter: SendAmountViewModel.fromStore,
      onInitialBuild: (viewModel) {
        setState(() {
          dropdownValue = viewModel.tokens[0];
        });
      },
      builder: (_, viewModel) {
        _onKeyPress(VirtualKeyboardKey key) {
          if (key.keyType == VirtualKeyboardKeyType.String) {
            if (amountText == "0") {
              amountText = "";
            }
            amountText = amountText + key.text;
          } else if (key.keyType == VirtualKeyboardKeyType.Action) {
            switch (key.action) {
              case VirtualKeyboardKeyAction.Backspace:
                if (amountText.length == 0) return;
                amountText = amountText.substring(0, amountText.length - 1);
                break;
              case VirtualKeyboardKeyAction.Return:
                amountText = amountText + '\n';
                break;
              case VirtualKeyboardKeyAction.Space:
                amountText = amountText + key.text;
                break;
              default:
            }
          }
          setState(() {});
          if (amountText == "") {
            amountText = "0";
          }
          if (viewModel.isProMode) {
            if (args.sendToCashMode) {
              try {
                double amount = double.parse(amountText);
                BigInt currentBalance =
                    toBigInt(amount, args.erc20Token.decimals);
                if (amount > 0 && args.erc20Token.amount >= currentBalance) {
                  controller.forward();
                } else {
                  controller.reverse();
                }
              } catch (e) {
                controller.reverse();
              }
            } else {
              try {
                double amount = double.parse(amountText);
                BigInt currentBalance =
                    toBigInt(amount, args.erc20Token.decimals);
                if (amount > 0 && args.erc20Token.amount >= currentBalance) {
                  controller.forward();
                } else {
                  controller.reverse();
                }
              } catch (e) {
                controller.reverse();
              }
            }
          } else {
            try {
              BigInt balance = dropdownValue == viewModel.tokens[0]
                  ? viewModel.balance
                  : viewModel.secondaryTokenBalance;
              double amount = double.parse(amountText);
              if (amount > 0 &&
                  balance >= toBigInt(amount, dropdownValue.decimals)) {
                controller.forward();
              } else {
                controller.reverse();
              }
            } catch (e) {
              controller.reverse();
            }
          }
        }

        List dropOptions;
        bool hasSecondToken = viewModel.community.secondaryToken != null &&
            (viewModel.community.secondaryToken.address != null &&
                viewModel.community.secondaryToken.address != '');
        if (hasSecondToken) {
          dropOptions = buildDropdownMenuItems(viewModel.tokens);
        }

        String symbol = args.erc20Token != null
            ? args.erc20Token.symbol
            : viewModel.token.symbol;
        return MainScaffold(
            withPadding: true,
            title: title,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(I18n.of(context).how_much,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                            !hasSecondToken
                                ? Container(
                                    padding:
                                        EdgeInsets.only(top: 30.0, bottom: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: <Widget>[
                                        Text('$amountText ',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 50,
                                                fontWeight: FontWeight.w900)),
                                        Text(symbol,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20.0, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: <Widget>[
                                            Text('$amountText ',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 50,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: DropdownButtonHideUnderline(
                                            child: Center(
                                              child: DropdownButton(
                                                hint: Container(
                                                    alignment: Alignment.center,
                                                    width: 100,
                                                    child:
                                                        Text('Choose token')),
                                                value: dropdownValue,
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                  return viewModel.tokens
                                                      .map<Widget>((Token token) => Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: 100,
                                                          child: Text(
                                                              token.symbol,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900))))
                                                      .toList();
                                                },
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    dropdownValue = newValue;
                                                  });
                                                },
                                                items: dropOptions,
                                              ),
                                            ),
                                          )),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      VirtualKeyboard(
                          height: MediaQuery.of(context).size.height * 0.37,
                          fontSize: 28,
                          textColor: Theme.of(context).primaryColor,
                          type: VirtualKeyboardType.Numeric,
                          onKeyPress: _onKeyPress),
                    ]),
              )
            ],
            footer: Center(
                child: SlideTransition(
              position: offset,
              child: PrimaryButton(
                labelFontWeight: FontWeight.normal,
                label: I18n.of(context).continue_with +
                    ' $amountText ${hasSecondToken ? (dropdownValue?.symbol ?? '') : (viewModel?.token?.symbol ?? '')}',
                onPressed: () {
                  if (hasSecondToken) {
                    args.tokenToSend = dropdownValue;
                  }
                  args.amount = num.parse(amountText);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => SendReviewScreen(
                                pageArgs: args,
                              )));
                },
                preload: isPreloading,
                width: 300,
              ),
            )));
      },
    );
  }
}
