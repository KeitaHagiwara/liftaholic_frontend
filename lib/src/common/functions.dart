// ---------------------------
// プログレスの数値を計算する
// ---------------------------
// ・params
//   _user_training_id: String
//   _training_set_list: List
//     exp) [{reps: 3, kgs: 70.0, time: 00:00, is_completed: true}, {reps: 3, kgs: 70.0, time: 00:00, is_completed: false}]
//
// ・return
//   progress: int
//
int calc_progress(String _user_training_id, List _training_set_list) {
  var progress = 0.0;
  var p_unit = 100 / _training_set_list.length;
  for (int i = 0; i < _training_set_list.length; i++) {
    if (_training_set_list[i]['is_completed']) {
      progress += p_unit;
    }
  }
  return progress.ceil();
}
