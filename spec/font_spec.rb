require_relative 'spec_helper'

describe 'Asciidoctor::PDF::Converter - Font' do
  context 'default' do
    it 'should not apply fallback font when using default theme' do
      input_file = Pathname.new fixture_file 'i18n-font-test.adoc'
      to_file = to_pdf_file input_file, 'font-i18n-default.pdf'
      (expect to_file).to visually_match 'font-i18n-default.pdf'
    end

    it 'should apply fallback font when using default theme with fallback font' do
      input_file = Pathname.new fixture_file 'i18n-font-test.adoc'
      to_file = to_pdf_file input_file, 'font-i18n-default-with-fallback.pdf', attribute_overrides: { 'pdf-theme' => 'default-with-fallback-font' }
      (expect to_file).to visually_match 'font-i18n-default-with-fallback.pdf'
    end
  end

  context 'Kerning' do
    it 'should enable kerning when using default theme' do
      to_file = to_pdf_file <<~'EOS', 'font-kerning-default.pdf'
      [%hardbreaks]
      AVA
      Aya
      WAWA
      WeWork
      DYI
      EOS

      (expect to_file).to visually_match 'font-kerning-default.pdf'
    end

    it 'should enable kerning when using base theme' do
      to_file = to_pdf_file <<~'EOS', 'font-kerning-base.pdf', attribute_overrides: { 'pdf-theme' => 'base' }
      [%hardbreaks]
      AVA
      Aya
      WAWA
      WeWork
      DYI
      EOS

      (expect to_file).to visually_match 'font-kerning-base.pdf'
    end

    it 'should allow theme to disable kerning' do
      to_file = to_pdf_file <<~'EOS', 'font-kerning-disabled.pdf', pdf_theme: { base_font_kerning: 'none' }
      [%hardbreaks]
      AVA
      Aya
      WAWA
      WeWork
      DYI
      EOS

      (expect to_file).to visually_match 'font-kerning-disabled.pdf'
    end
  end

  context 'Separators' do
    it 'should not break line at location of no-break space' do
      input = (%w(a b c d).reduce([]) {|accum, it| accum << (it * 20) }.join ' ') + ?\u00a0 + ('e' * 20)
      pdf = to_pdf input, analyze: true
      text = pdf.text
      (expect text).to have_size 2
      (expect text[0][:string]).to end_with 'c'
      (expect text[1][:string]).to start_with 'd'
      (expect text[1][:y]).to be < text[0][:y]
    end

    it 'should use zero-width space a line break opportunity' do
      input = (%w(a b c d e f).reduce([]) {|accum, it| accum << (it * 5) + ?\u200b + (it * 10) }.join ' ')
      pdf = to_pdf input, analyze: true
      text = pdf.text
      (expect text).to have_size 2
      (expect text[0][:string]).to eql 'aaaaaaaaaaaaaaa bbbbbbbbbbbbbbb ccccccccccccccc ddddddddddddddd eeeeeeeeeeeeeee fffff'
      (expect text[1][:string]).to eql 'ffffffffff'
      (expect text[1][:y]).to be < text[0][:y]
    end
  end
end
