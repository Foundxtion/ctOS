import sqlalchemy as sql
import pandas as pd


def create_engine(
    username: str, password: str, host: str, port: str, dbname: str
) -> sql.engine.Engine:
    return sql.create_engine(
        f"postgresql://{username}:{password}@{host}:{port}/{dbname}"
    )


def export_metadata(
    engine: sql.engine.Engine, df: pd.DataFrame, tablename: str, start_index: int
) -> None:
    df.reset_index(drop=True, inplace=True)
    df.index += start_index - len(df)
    print(df)
    df.to_sql(tablename, engine, if_exists="append")
