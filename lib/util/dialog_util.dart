import 'package:flutter/material.dart';

const  ALERT_DIALOG_TITLE_STYLE = TextStyle(
    color: Colors.black
);

class DialogUtil {
  DialogUtil._();

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    String title = '提示',
    required String content,
    String cancelText = '取消',
    String confirmText = '确定',
    TextStyle textStyle = ALERT_DIALOG_TITLE_STYLE,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title,style: textStyle,),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
