import 'package:flutter/material.dart';
import 'package:scv_app/UrnikPages/components/otherStyleBox.dart';
import 'package:scv_app/UrnikPages/urnikData.dart';
import 'package:scv_app/Data/data.dart';

class DetailUrnik extends StatefulWidget {
  DetailUrnik(this.context, this.urnikData,
      {Key key,
      this.ucilnica = "",
      this.krajsava = "",
      this.id = 0,
      this.trajanje = "",
      this.dogodek = "",
      this.ucitelj = "",
      this.styleOfBox = OtherStyleBox.normalno})
      : super(key: key);

  final BuildContext context;
  final UrnikData urnikData;
  final String ucilnica;
  final String krajsava;
  final int id;
  final String trajanje;
  final String dogodek;
  final String ucitelj;
  final OtherStyleBox styleOfBox;

  _DetailUrnikState createState() => _DetailUrnikState();
}

class _DetailUrnikState extends State<DetailUrnik> {
  final double paddingInSizeBox = 15;
  final double paddingFromScreenStartEnd = 37;

  Widget content() {
    return LayoutBuilder(builder: ((context, constraints) {
      final double mainFontSize = MediaQuery.of(context).size.width * 0.045;
      final Color textColor = widget.styleOfBox == OtherStyleBox.normalno
          ? Theme.of(context).primaryColor
          : Colors.black;
      final double bigFontSize = MediaQuery.of(context).size.width * 0.069;
      final double spaceBetweenLines = 10;

      var textForClass = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: '${widget.ucilnica}',
            style: TextStyle(
                fontSize: bigFontSize,
                fontWeight: FontWeight.w500,
                color: textColor,
                decoration: widget.styleOfBox != OtherStyleBox.odpadlo
                    ? TextDecoration.none
                    : TextDecoration.lineThrough)),
      );
      textForClass.layout();
      double sizeOfBox = MediaQuery.of(context).size.width -
          (2 * paddingFromScreenStartEnd) -
          (2 * paddingInSizeBox);
      double sizeForRichText = sizeOfBox - textForClass.size.width - 10;
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: sizeForRichText,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: textColor,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "${widget.id}. ura: ",
                              style: TextStyle(fontSize: mainFontSize),
                            ),
                            TextSpan(
                              text:
                                  "${widget.dogodek != "" ? widget.dogodek : widget.krajsava}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: mainFontSize,
                                  decoration:
                                      widget.styleOfBox != OtherStyleBox.odpadlo
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                      )),
                  Padding(padding: EdgeInsets.only(top: spaceBetweenLines)),
                  Text(
                    "Čas: ${widget.trajanje}",
                    style: TextStyle(fontSize: mainFontSize, color: textColor),
                  ),
                  Padding(padding: EdgeInsets.only(top: spaceBetweenLines)),
                  widget.styleOfBox != OtherStyleBox.dogodek
                      ? SizedBox(
                          width: sizeOfBox -
                              (widget.styleOfBox == OtherStyleBox.normalno
                                  ? 15
                                  : 20),
                          child: Text("Profesor/ica: ${widget.ucitelj}",
                              style: TextStyle(
                                  fontSize: mainFontSize, color: textColor)))
                      : SizedBox(),
                ],
              ),
              Positioned(
                child: Text(
                  textForClass.text.toPlainText(),
                  style: textForClass.text.style,
                ),
                right: 0,
                top: -5,
              ),
              widget.styleOfBox != OtherStyleBox.normalno
                  ? Positioned(
                      child: Image.asset(imagesForStyle[widget.styleOfBox]),
                      right: 0,
                      bottom: 0,
                    )
                  : SizedBox(),
            ],
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 25,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Padding(
            child: Container(
                // height: 150,
                padding: EdgeInsets.all(paddingInSizeBox),
                decoration: BoxDecoration(
                  color: widget.styleOfBox == OtherStyleBox.normalno
                      ? Theme.of(context).cardColor
                      : colorsForStyles[widget.styleOfBox],
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 3,
                      offset: Offset(0, 6), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [this.content()])),
            padding: EdgeInsets.only(
                left: paddingFromScreenStartEnd,
                right: paddingFromScreenStartEnd),
          )
        ]))));
  }
}
