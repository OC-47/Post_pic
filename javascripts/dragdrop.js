var canvas;
var context;
$(function(){
 // canvas 初期化
canvas = $("#img_canvas").get(0);
context = canvas.getContext("2d");
// プルダウンにローカルストレージの中身をセット
for(var i=0 ; i<localStorage.length ; i++){
$("#ls_select").append($('<option>').attr({value: i+1}).text("image"+String(i+1)));
 }
// localStorageのプルダウンの値が変わったときの動作。
// canvasに画像を反映する
$("#ls_select").change(function(){
if($(this).val().length > 0){
 // canvasにLocalStorageの中身を表示
var img = document.createElement('img');
img.src = localStorage.getItem($(this).val());
img.onload = function() {
canvas.width = img.width;
canvas.height = img.height;
context.drawImage(img, 0, 0);
}
}
});
// localStorage保存ボタンを押したときの動作。
// localStorageに画像を保存して、プルダウン更新
$("#save_ls_button").click(function() {
canvas_data = canvas.toDataURL();
key = localStorage.length+1
localStorage.setItem(key, canvas_data);
$("#ls_select").append($('<option>').attr({value: key}).text("image"+key));
$("#ls_select").val("");
alert("ローカルストレージに保存したよ。今"+(localStorage.length)+"個のデータがあるよ。");
});
// localStorageクリアボタンを押したときの動作。
// localStorageをクリアして、プルダウン更新
$("#clear_ls_button").click(function() {
var l_length = localStorage.length;
if(l_length > 0){
localStorage.clear();
$("#ls_select").children().remove();
$("#ls_select").append($('<option>').attr({value: ""}).text("localStorage"));
alert("ローカルストレージを削除したよ。" + l_length + "個のデータを削除したよ");
 }else{
alert("ローカルストレージの中身、今空だよ。");
}
});
});
function onDrop(event){
// drop されたファイルの取得
var f = event.dataTransfer.files[0];
// drop されたファイルが画像ファイルの場合の処理
if(/^image/.test(f.type)){
// 画像ファイルを読み込むための準備 
var img = document.createElement('img');
var fr = new FileReader();
fr.onload = function(){
img.src = fr.result;
img.onload = function() {
// jquery ajax を使ってPOST
new $.ajax({
url: "/post_img",
type: "POST",
data: {file: img.src},
success: function(){
// canvas に画像描画
canvas.width = img.width;
canvas.height = img.height;
context.drawImage(img, 0, 0);
$("#save_ls_button").css("visibility","visible");
},
error: function(){ alert("ごめん失敗した。");},
complete: function(){ alert("保存した！"); }
});
}
}
fr.readAsDataURL(f);
}
// ブラウザがファイル自体を表示するのを防止
event.preventDefault();
} // end funciton [openDrop]
function onDragOver(event){
event.preventDefault();
} // end function [onDragOver]