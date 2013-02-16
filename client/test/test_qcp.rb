require 'qcp'
require 'test/unit'

# StringIO#noecho does not appear to exist,
# even though it's present on $stdout et al.
# We need to define it for mocking the standard IOs.
class StringIO
  def noecho
    yield self
  end
end

class TestQcpApp < Test::Unit::TestCase
  def setup
    @qcp_file = Tempfile.new('test')
  end

  def teardown
    @qcp_file.delete rescue nil
  end

  def cmd(*args)
    qcp_args = args[0...args.length - 1]
    input = args.last

    stdout = StringIO.new('', 'w+')
    stderr = StringIO.new('', 'w+')
    stdin = StringIO.new(input, 'r')
    exit = Qcp::App.new.run(@qcp_file.path, qcp_args, stdout, stderr, stdin)

    stdout.rewind
    stderr.rewind

    return {
      :exit => exit,
      :out => stdout.read,
      :err => stderr.read
    }
  end

  def test_help
    c = cmd('help', '')
    assert_equal(0, c[:exit])
  end
end
