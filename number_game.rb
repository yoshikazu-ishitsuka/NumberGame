# encoding: utf-8
require "io/console"

### ここからメソッド ###
# 最初のメッセージ
def first_message
  puts <<-TEXT
  
            ################################
            ### ヌメロン風数字当てゲーム ###
            ###        スタート！        ###
            ################################  

  TEXT
  sleep(0.5)
end

# 重複なしの数字3桁か判定する
def unique_three_digits?(hand)
  hand.match(/\A\d{3}\z/) && hand.split("").uniq.length == 3
end

# 手札を入力する
def input_hand(name)
  print "プレイヤー#{name}さん あなたの手札を好きな数字3桁で入力してください。\n入力受付中 => "
  hand = STDIN.noecho(&:gets).chop
  puts "\n\n"

  until unique_three_digits?(hand)
    print "無効な入力です。もう一度入力してください。\n入力受付中 => "
    hand = STDIN.noecho(&:gets).chop
    puts "\n\n"
  end

  puts "----------- 入力完了 ---------------\n\n\n\n"
  sleep(0.5)

  hand
end

# コール履歴の出力
def call_history(list)
  puts "###### これまでのコール履歴 ########"
  list.each { |hash| puts "# 第#{hash[:turn]}ターン：#{hash[:call]} => #{hash[:judgement]} #" }
  puts "####################################\n\n"
end

# コールする数字を入力する
def input_call
  print "コールする数字を入力してください。\n入力受付中 => "
  call = gets.chomp
  puts "\n"

  until unique_three_digits?(call)
    print "無効な入力です。もう一度入力してください。\n入力受付中 => "
    call = gets.chomp
    puts "\n"
  end

  call
end

# EAT-BITE判定
def judge_eat_bite(call_array, hand_array)
  eat = bite = 0

  3.times do |i|
    3.times do |j|
      if call_array[i] == hand_array[j] && i == j
        eat += 1
      elsif call_array[i] == hand_array[j]
        bite += 1
      end
    end
  end

  eat == 3 ? judgement = "[3]EAT! 見事相手の手札を見破りました!" : judgement = "[#{eat}]EAT-[#{bite}]BITE"

  puts "#{judgement}\n\n\n"

  judgement
end

# コールターン
def call_turn(name, turn, hand_array, list)
  puts "プレイヤー#{name}さんの第#{turn}ターンです。\n\n"

  call_history(list) if list.length > 0

  call = input_call

  print "『#{call}』ですね。 結果は"
  5.times do
    sleep(0.3)
    print "."
  end
  puts "\n\n"

  call_array = call.split("")
  judgement = judge_eat_bite(call_array, hand_array)

  sleep(0.5)
  puts "----------- ターン終了 ---------------\n\n\n\n"
  sleep(0.5)

  { turn: turn, call: call, judgement: judgement }
end

# 3EATが含まれているか判定する
def three_eat?(list)
  three_eat = "[3]EAT! 見事相手の手札を見破りました!"
  list.any? { |hash| hash.value?(three_eat) }
end

### ここから出力開始 ###
first_message

a_hand = input_hand("A")
a_hand_array = a_hand.split("")

b_hand = input_hand("B")
b_hand_array = b_hand.split("")

turn = 1
a_called_list = []
b_called_list = []

while true
  a_call = call_turn("A", turn, b_hand_array, a_called_list)
  a_called_list.push(a_call)
  b_call = call_turn("B", turn, a_hand_array, b_called_list)
  b_called_list.push(b_call)

  break if three_eat?(a_called_list) || three_eat?(b_called_list)

  turn += 1
end

result = if three_eat?(a_called_list) && three_eat?(b_called_list)
    "引き分け"
  elsif three_eat?(a_called_list)
    "プレイヤーAさんの勝ち!"
  elsif three_eat?(b_called_list)
    "プレイヤーBさんの勝ち!"
  end

puts "ゲーム終了！ 最終結果は『#{result}』です！\n\n"

# 1.プレイヤーAが0~9の10枚のカードの中から手札を決める
# 2.プレイヤーBが0~9の10枚のカードの中から手札を決める
# 3.プレイヤーAが過去にコールしたことがあれば履歴を表示する
# 4.プレイヤーAが数字をコールする
# 5.プログラムで[EAT-BITE]を発表する
# 6.プレイヤーBが過去にコールしたことがあれば履歴を表示する
# 7.プレイヤーBが数字をコールする
# 8.プログラムで[EAT-BITE]を発表する
# 9.以降3~8を繰り返し3EATが出たら終了する
