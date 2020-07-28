import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton(
      {this.fontSize,
      this.labelFontWeight,
      this.onPressed,
      this.label,
      this.width,
      this.height,
      this.opacity = 0.4,
      this.preload,
      this.colors,
      this.disabled = false,
      this.labalColor});
  final double opacity;
  final GestureTapCallback onPressed;
  final String label;
  final FontWeight labelFontWeight;
  final double width;
  final double height;
  final bool preload;
  final bool disabled;
  final double fontSize;
  final List<Color> colors;
  final Color labalColor;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? opacity : 1,
      child: Container(
        width: width ?? 255.0,
        height: height ?? 50.0,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors ??
                  [
                    Theme.of(context).primaryColorLight,
                    Theme.of(context).primaryColorDark,
                  ],
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
            border: Border.all(
                color: Theme.of(context).primaryColor.withAlpha(14))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onPressed,
              borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
              highlightColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
              splashColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
              child: Center(
                child: (preload == null || preload == false)
                    ? Text(
                        label,
                        style: TextStyle(
                            color: labalColor ?? Colors.white,
                            fontSize: this.fontSize ?? 18,
                            fontWeight:
                                this.labelFontWeight ?? FontWeight.w700),
                      )
                    : Container(
                        child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.white)),
                        width: 21.0,
                        height: 21.0,
                        margin: EdgeInsets.only(left: 28, right: 28),
                      ),
              )),
        ),
      ),
    );
  }
}
