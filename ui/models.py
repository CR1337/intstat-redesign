from pydantic import BaseModel
from typing import List


class Zo(BaseModel):
    pass



class Lizenzen_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Lizenzen zu.
    """

 
 
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    lizenzen: Lizenzen  # Verweis auf die zugeordnet Lizenz.
 
    def get_values(self) -> List[Daten]:
        pass  # TODO

 


class Quellen(Zo):
    """
    Tabelle zur Verwaltung von Datenquellen.
    """

    name_de: str  # Vollständiger Name der Quelle auf Deutsch.
    name_en: str  # Vollständiger Name der Quelle auf Englisch.
    name_kurz_de: str  # Kurzer Name der Quelle auf Deutsch.
    name_kurz_en: str  # Kurzer Name der Quelle auf Englisch.
    url: str  # Link zu der Quelle.
 
 
 
 


class Metadaten(Zo):
    """
    Tabelle zur Verwaltung von Metadaten, die Datenpunkten zugeordnet werden können (z.B. methodische Hinweise, Fußnoten).
    """

    kuerzel: str  # Kürzel für das Metadatum.
    bezeichnung: str  # Ausführliche Bezeichnung des Metadatums.
 
 
 
 


class Lizenzen(Zo):
    """
    Tabelle zur Verwaltung der Lizenzen, unter denen die statistischen Daten veröffentlicht werden.
    """

    name: str  # Name der Lizenz (z.B. CC BY 4.0).
    url: str  # URL zur vollständigen Lizenzbeschreibung.
    extra_bedingungen: bool  # Gibt an, ob zusätzliche Bedingungen für die Nutzung der Daten bestehen.
 
 
 
 


class Laendergruppen(Zo):
    """
    Tabelle zur Verwaltung von Ländergruppen (z.B. EU, OECD, G7).
    """

    name_de: str  # Name der Ländergruppe auf Deutsch.
    name_en: str  # Name der Ländergruppe auf Englisch.
 
 
 
 


class Quellen_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Quellen zu.
    """

 
 
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    quellen: Quellen  # Verweis auf die zugeordnete Quelle.
 
    def get_values(self) -> List[Daten]:
        pass  # TODO

 


class Metadaten_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Metadaten zu.
    """

 
 
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    metadaten: Metadaten  # Verweis auf das zugeordnete Metadatum.
 
    def get_values(self) -> List[Daten]:
        pass  # TODO

 


class Laendergruppen_zo(BaseModel):
    """
    Tabelle zur Zuordnung von Ländern zu Ländergruppen (z.B. Mitgliedschaft eines Landes in einer Gruppe).
    """

 
 
    laender: Laender  # Verweis auf das zugeordnete Land.
    laendergruppen: Laendergruppen  # Verweis auf die zugeordnete Ländergruppe.
 
    def get_values(self) -> List[Laender]:
        pass  # TODO

 


class Daten(Zo):
    """
    Tabelle für die Speicherung von statistischen Einzelwerten (Zeitreihen) zu Ländern und Indikatoren.
    """

    datum: datetime  # Datum, an dem der Wert erhoben oder veröffentlicht wurde.
    wert: float  # Erfasster numerischer Wert für das jeweilige Land und den Indikator am angegebenen Datum.
    berechnet: bool  # Gibt an, ob der Wert berechnet wurde.
 
    downloadquellen: 
    lizenzen: 
    metadaten: 
    quellen: 
    ugl: 
 
    laender: Laender  # Verweis auf das Land, für das der Wert gilt.
    indikatoren: Indikatoren  # Verweis auf den Indikator, zu dem der Wert gehört.
 
 


class Kontinente(Zo):
    """
    Tabelle zur Verwaltung der Kontinente, denen Länder zugeordnet werden können.
    """

    name_de: str  # Name des Kontinents auf Deutsch.
    name_en: str  # Name des Kontinents auf Englisch.
 
 
 
 


class Themen(Zo):
    """
    Tabelle welche Themen verwaltet, denen Indikatoren zugeordnet sind.
    """

    name_de: str  # Name des Themas auf Deutsch.
    name_en: str  # Name des Themas auf Englisch.
    farbe_r: int  # Rotwert der Farbzuordnung für das Thema (0-255).
    farbe_g: int  # Grünwert der Farbzuordnung für das Thema (0-255).
    farbe_b: int  # Blauwert der Farbzuordnung für das Thema (0-255).
 
 
 
 


class Ugl_zo(BaseModel):
    """
    Diese Tabelle ordnet Daten ihre Untergliederungswerte zu.
    """

 
 
    untergliederungswerte: Ugl_werte  # Verweis auf den zugeordneten Untergliederungswert.
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
 
    def get_values(self) -> List[Daten]:
        pass  # TODO

 


class Ugl_werte(Zo):
    """
    Tabelle zur Verwaltung der Werte der Untergliederungen von Indikatoren.
    """

    name: str  # Name des Untergliederungwertes.
 
 
    untergliederungen: Ugl  # Optionalee Referenz auf die Untergliederung.
    laender: Laender  # Referenz auf ein Land.
 
 


class Laender(Zo):
    """
    Tabelle zur Verwaltung der Länder mit ISO-Codes und Namensreferenzen.
    """

    iso2: str  # ISO-2-Ländercode gemäß internationalem Standard (z.B. 'DE' für Deutschland).
    iso3: str  # ISO-3-Ländercode gemäß internationalem Standard (z.B. 'DEU' für Deutschland).
 
    laendergruppen: 
 
    kontinente: Kontinente  # Verweis auf den Kontinent, dem das Land zugeordnet ist.
    laendernamen_de: Laendernamen  # Verweis auf den deutschen Namen des Landes.
    laendernamen_en: Laendernamen  # Verweis auf den englischen Namen des Landes.
 
 


class Downloadquellen_zo(BaseModel):
    """
    Diese Tabelle ordnet Datenpunkten ihre Download-Quellen zu.
    """

 
 
    daten: Daten  # Verweis auf den zugeordneten Datenpunkt.
    quellen: Quellen  # Verweis auf die zugeordnete Download-Quelle.
 
    def get_values(self) -> List[Daten]:
        pass  # TODO

 


class Indikatoren(Zo):
    """
    Tabelle zur Verwaltung der statistischen Indikatoren.
    """

    faktor: float  # Faktor zur Multiplikation mit dem Indikatorwerts, um den korrekten Wert zu erhalten.
    dezimalstellen: int  # Anzahl der Dezimalstellen, mit denen der Wert angezeigt wird.
    name_de: str  # Name des Indikators auf Deutsch.
    name_en: str  # Name des Indikators auf Englisch.
    beschreibung_de: str  # Ausführliche Beschreibung des Indikators auf Deutsch.
    beschreibung_en: str  # Ausführliche Beschreibung des Indikators auf Englisch.
    quellen_indikatoren_id: str  # ID des Indikators bei der jeweiligen Quelle (optional).
 
 
    themen: Themen  # Verweis auf das Thema, dem der Indikator zugeordnet ist.
    einheiten: Einheiten  # Verweis auf die Einheit, in der der Indikator gemessen wird.
 
 


class Laendernamen(Zo):
    """
    Tabelle zuer Verwaltung von Ländernamen. Ein Land kann mehrere Ländernamen haben. Jedes Land hat einen deutschen und einen englischen Namen.
    """

    name: str  # Name eines Landes.
 
 
    laender: Laender  # Verweis auf das Land, dem der Name zugeordnet ist. (optional)
 
 


class Nutzer(Zo):
    """
    Diese Tabelle speichert alle Nutzer.
    """

    name: str  # Name des Nutzers.
 
 
 
 


class Einheiten(Zo):
    """
    Tabelle zur Verwaltung der Einheiten, in denen statistische Werte angegeben werden.
    """

    faktor: float  # Faktor zur Umrechnung in die Basiseinheit.
    symbol_de: str  # Symbol der Einheit auf Deutsch.
    symbol_en: str  # Symbol der Einheit auf Englisch.
 
 
    basis_einheiten: Einheiten  # Optionale Referenz auf eine Basiseinheit, falls die Einheit abgeleitet ist.
 
 


class Ugl(Zo):
    """
    Tabelle zur Verwaltung der möglichen Untergliederungen eines Indikators.
    """

    name: str  # Name der Untergliederung.
 
 
 
 

 

