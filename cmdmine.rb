# -*- coding: utf-8 -*-
#
#
=begin
	$ redissue -g  # 一覧取得
	$ redissue -g  --id 1 # 特定Issue取得
	$ redissue -p --subject "てすとー" --description "本文" # 登録
	$ redissue -u --id 1 --subject "てすとーー" --description "本文ー" # 更新
	$ redissue -d --id 1 # 削除
=end
require 'open3'

#======================================
class RedcuineRunner
	TEMP_FILE = '.work'
	CONFIG_FILE = '~/.redcuine/config.yml'
	EDITOR = 'vim'
	CMD = 'redissue'
	CMD_LIST = {
		'init'		=> '',
		'config'	=> '',
		'list'		=> '-g',
		'show'		=> '-g --id',
	}
	CMD_INFO = {
		'init'		=> "初期化を実行します",
		'exit'		=> "スクリプトを終了します",
		'config'	=> "設定ファイルを編集します",
		'list'		=> "チケットの一覧を取得します",
		'show <id>'	=> "<id>のチケットの詳細を#{EDITOR}で表示します",
	}

	#==================================
	def initialize
	end

	#==================================
	def help
		CMD_INFO.each_key do |key| puts "#{key} : #{CMD_INFO[key]}" end
	end

	#==================================
	def command? func
		CMD_LIST.include? func
	end

	#==================================
	def id_title? str
		str.match '- id: '
	end

	#==================================
	def subject? str
		str.match '  subject: '
	end

	#==================================
	def run cmd
		Open3.popen3(cmd) do |stdin, stdout, stderr| 
			stdout.readlines.each do |line|
				yield line if block_given?
			end
		end
	end

	#==================================
	def download id
		work = File.open( TEMP_FILE, 'w' )
		run "#{CMD} #{CMD_LIST['show']} #{id}" do |line|
			work << line
		end
		work.close
		TEMP_FILE
	end

	#==================================
	def init *params
		run "#{CMD}" do |line| puts line end
	end

	#==================================
	def config *params
		system "#{EDITOR} #{CONFIG_FILE}"
	end

	#==================================
	def list *params
		info = ''
		run "#{CMD} #{CMD_LIST['list']}" do |line|
			str = line.chomp
			if id_title? str then
				puts info
				info = str 
			end
			info += str if subject? str
		end
	end

	#==================================
	def show *params
		file = download params[0][0]
		system "#{EDITOR} #{file}"
		system "rm #{file}"
	end
end


#======================================
class CmdMine
	#==================================
	def initialize
		@runner = RedcuineRunner.new
	end

	#==================================
	def run input
		params = input.split(' ')
		func = params[0]
		args = params[1..params.length]
		return true if input.length < 1
		return false if func.match 'exit'
		if @runner.command? func then
			@runner.send( func, args ) 
		else
			@runner.help
		end
	end
end

#--------------------------------------
cmdmine = CmdMine.new
begin
	print '> '
end while cmdmine.run gets.chomp


