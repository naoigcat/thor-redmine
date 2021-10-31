class Entrypoint < Thor
  desc "export", "Export issues to Google Sheets"
  def export
    session = GoogleDrive::Session.from_service_account_key(".key.json")
    spreadsheet = session.spreadsheet_by_key(ENV["SHEETS_KEY"])
    worksheet = spreadsheet.worksheet_by_title("issues")
    if worksheet.num_rows.zero?
      %w[
        #
        プロジェクト
        トラッカー
        親チケット
        ステータス
        優先度
        題名
        作成者
        担当者
        更新日
        カテゴリ
        対象バージョン
        開始日
        期日
        予定工数
        合計予定工数
        作業時間
        合計作業時間
        進捗率
        作成日
        終了日
        説明
        注記
      ].each.with_index(1) do |header, index|
        worksheet[1, index] = header
      end
    end
    endpoint = ENV["API_ENDPOINT"]
    key = ENV["API_KEY"]
    issues = loop.reduce([[], 0]) do |(memo, offset), _|
      res = get("#{endpoint}/issues.json?key=#{key}&status_id=*&offset=#{offset}&limit=100")
      memo.concat(res.issues)
      break memo if res.total_count <= res.offset + res.limit

      sleep 1
      [memo, offset + res.limit]
    end
    issues = issues.map do |issue|
      get("#{endpoint}/issues/#{issue.id}.json?key=#{key}&include=journals").issue
    end
    issues.reverse.each.with_index(2) do |issue, index|
      worksheet[index,  1] = issue.id
      worksheet[index,  2] = issue.project&.name
      worksheet[index,  3] = issue.tracker&.name
      worksheet[index,  4] = issue.parent&.id
      worksheet[index,  5] = issue.status&.name
      worksheet[index,  6] = issue.priority&.name
      worksheet[index,  7] = issue.subject
      worksheet[index,  8] = issue.author&.name
      worksheet[index,  9] = issue.assigned_to&.name
      worksheet[index, 10] = issue.updated_on
      worksheet[index, 11] = issue.category&.name
      worksheet[index, 12] = issue.fixed_version&.name
      worksheet[index, 13] = issue.start_date
      worksheet[index, 14] = issue.due_date
      worksheet[index, 15] = issue.estimated_hours
      worksheet[index, 16] = issue.total_estimated_hours
      worksheet[index, 17] = issue.spent_hours
      worksheet[index, 18] = issue.total_spent_hours
      worksheet[index, 19] = issue.done_ratio
      worksheet[index, 20] = issue.created_on
      worksheet[index, 21] = issue.closed_on
      worksheet[index, 22] = issue.description
      worksheet[index, 23] = issue.journals.reject do |journal|
        journal.notes&.empty?
      end.map do |journal|
        <<~JOURNAL
        By #{journal.user&.name} On #{journal.created_on}
        #{journal.notes}
        JOURNAL
      end.join("\n").chomp
    end
    worksheet.save
  end
  no_commands do
    def get(uri)
      puts "=> #{uri.sub(/#{ENV["ACCESS_KEY"]}/, "********")}"
      Hashie::Mash.new(JSON.parse(Net::HTTP.get(URI.parse(uri)))).tap do
        sleep 1
      end
    end
  end
end
