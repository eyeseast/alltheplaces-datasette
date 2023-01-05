from datasette import hookimpl


@hookimpl
def prepare_connection(conn):
    conn.create_function("pause", 0, fake_pause)


def fake_pause():
    "Override pause so we can't crash a server"
    return "Pause is disabled"
