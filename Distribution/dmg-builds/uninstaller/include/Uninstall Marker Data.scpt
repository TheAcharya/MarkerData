FasdUAS 1.101.10   ��   ��    k             l     ��  ��    %  Uninstall Tool for Marker Data     � 	 	 >   U n i n s t a l l   T o o l   f o r   M a r k e r   D a t a   
  
 l     ��������  ��  ��        l     ��  ��    F @ Confirm with the user before proceeding with the uninstallation     �   �   C o n f i r m   w i t h   t h e   u s e r   b e f o r e   p r o c e e d i n g   w i t h   t h e   u n i n s t a l l a t i o n      l     ����  I    ��  
�� .sysodlogaskr        TEXT  m        �  . T h i s   U n i n s t a l l e r   T o o l   w i l l   c o m p l e t e l y   a n d   p e r m a n e n t l y   r e m o v e   M a r k e r   D a t a   f r o m   y o u r   s y s t e m ,   i n c l u d i n g   C a c h e s ,   P r e f e r e n c e s ,   C o n f i g u r a t i o n s   a n d   D a t a b a s e s .  ��  
�� 
btns  J           m       �    A b o r t   &   Q u i t   ��  m         � ! ! * U n i n s t a l l   M a r k e r   D a t a��    �� " #
�� 
dflt " m     $ $ � % %  A b o r t   &   Q u i t # �� &��
�� 
disp & l  	  '���� ' I  	 �� (��
�� .sysorpthalis        TEXT ( m   	 
 ) ) � * *  a p p l e t . i c n s��  ��  ��  ��  ��  ��     + , + l    -���� - r     . / . n     0 1 0 1    ��
�� 
bhit 1 1    ��
�� 
rslt / o      ���� 0 
userchoice 
userChoice��  ��   ,  2 3 2 l     ��������  ��  ��   3  4 5 4 l     �� 6 7��   6 < 6 Set the name of the application you want to uninstall    7 � 8 8 l   S e t   t h e   n a m e   o f   t h e   a p p l i c a t i o n   y o u   w a n t   t o   u n i n s t a l l 5  9 : 9 l    ;���� ; r     < = < m     > > � ? ?  M a r k e r   D a t a = o      ���� 0 appname appName��  ��   :  @ A @ l     ��������  ��  ��   A  B C B l     �� D E��   D A ; Function to get the full path to the user's home directory    E � F F v   F u n c t i o n   t o   g e t   t h e   f u l l   p a t h   t o   t h e   u s e r ' s   h o m e   d i r e c t o r y C  G H G i      I J I I      �������� &0 gethomefolderpath getHomeFolderPath��  ��   J L     	 K K n      L M L 1    ��
�� 
psxp M l     N���� N I    �� O��
�� .earsffdralis        afdr O m     ��
�� afdrcusr��  ��  ��   H  P Q P l     ��������  ��  ��   Q  R S R l     �� T U��   T 4 . Check if the application is currently running    U � V V \   C h e c k   i f   t h e   a p p l i c a t i o n   i s   c u r r e n t l y   r u n n i n g S  W X W l   ~ Y���� Y Z    ~ Z [�� \ Z =   ) ] ^ ] n    ' _ ` _ 1   # '��
�� 
prun ` 4    #�� a
�� 
capp a o   ! "���� 0 appname appName ^ m   ' (��
�� boovtrue [ k   , n b b  c d c l  , ,�� e f��   e   Quit the application    f � g g *   Q u i t   t h e   a p p l i c a t i o n d  h i h O  , ; j k j I  5 :������
�� .aevtquitnull��� ��� null��  ��   k 4   , 2�� l
�� 
capp l o   0 1���� 0 appname appName i  m n m l  < A o p q o I  < A�� r��
�� .sysodelanull��� ��� nmbr r m   < =���� ��   p C = Add a delay if needed for the application to quit gracefully    q � s s z   A d d   a   d e l a y   i f   n e e d e d   f o r   t h e   a p p l i c a t i o n   t o   q u i t   g r a c e f u l l y n  t u t l  B B��������  ��  ��   u  v w v l  B B�� x y��   x A ; Verify if the application has been successfully terminated    y � z z v   V e r i f y   i f   t h e   a p p l i c a t i o n   h a s   b e e n   s u c c e s s f u l l y   t e r m i n a t e d w  {�� { Z   B n | }�� ~ | >  B N  �  n   B L � � � 1   H L��
�� 
prun � 4   B H�� �
�� 
capp � o   F G���� 0 appname appName � m   L M��
�� boovtrue } k   Q ^ � �  � � � l  Q Q�� � ���   � &   Application has been terminated    � � � � @   A p p l i c a t i o n   h a s   b e e n   t e r m i n a t e d �  ��� � I  Q ^�� ���
�� .sysoexecTEXT���     TEXT � b   Q Z � � � b   Q V � � � m   Q T � � � � � 
 e c h o   � o   T U���� 0 appname appName � m   V Y � � � � �    t e r m i n a t e d .��  ��  ��   ~ k   a n � �  � � � l  a a�� � ���   � * $ Unable to terminate the application    � � � � H   U n a b l e   t o   t e r m i n a t e   t h e   a p p l i c a t i o n �  ��� � I  a n�� ���
�� .sysoexecTEXT���     TEXT � b   a j � � � b   a f � � � m   a d � � � � � 2 e c h o   U n a b l e   t o   t e r m i n a t e   � o   d e���� 0 appname appName � m   f i � � � � �  .��  ��  ��  ��   \ k   q ~ � �  � � � l  q q�� � ���   � + % Application is not currently running    � � � � J   A p p l i c a t i o n   i s   n o t   c u r r e n t l y   r u n n i n g �  ��� � I  q ~�� ���
�� .sysoexecTEXT���     TEXT � b   q z � � � b   q v � � � m   q t � � � � � 
 e c h o   � o   t u���� 0 appname appName � m   v y � � � � � 4   i s   n o t   c u r r e n t l y   r u n n i n g .��  ��  ��  ��   X  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � , & Marker Data Files & Folders to Remove    � � � � L   M a r k e r   D a t a   F i l e s   &   F o l d e r s   t o   R e m o v e �  � � � l   � ����� � r    � � � � J    � � �  � � � l 	  � ����� � m    � � � � � � : / A p p l i c a t i o n s / M a r k e r   D a t a . a p p��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � 2 / M o v i e s / M a r k e r   D a t a   C a c h e��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � � / L i b r a r y / S a v e d   A p p l i c a t i o n   S t a t e / c o . t h e a c h a r y a . M a r k e r D a t a . s a v e d S t a t e��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � \ / L i b r a r y / H T T P S t o r a g e s / c o . t h e a c h a r y a . M a r k e r D a t a��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � x / L i b r a r y / H T T P S t o r a g e s / c o . t h e a c h a r y a . M a r k e r D a t a . b i n a r y c o o k i e s��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ���~�}� &0 gethomefolderpath getHomeFolderPath�~  �}   � m   � � � � � � � | / L i b r a r y / C o n t a i n e r s / c o . t h e a c h a r y a . M a r k e r D a t a . W o r k f l o w E x t e n s i o n��  ��  ��  ��   �  � � � l 	 � � ��|�{ � l  � � ��z�y � b   � � � � � I   � ��x�w�v�x &0 gethomefolderpath getHomeFolderPath�w  �v   � m   � � � � � � � � / L i b r a r y / A p p l i c a t i o n   S c r i p t s / c o . t h e a c h a r y a . M a r k e r D a t a . W o r k f l o w E x t e n s i o n�z  �y  �|  �{   �  � � � l 	 � � ��u�t � l  � � ��s�r � b   � � � � � I   � ��q�p�o�q &0 gethomefolderpath getHomeFolderPath�p  �o   � m   � � � � � � � P / L i b r a r y / A p p l i c a t i o n   S u p p o r t / M a r k e r   D a t a�s  �r  �u  �t   �  � � � l 	 � � �n�m  l  � ��l�k b   � � I   � ��j�i�h�j &0 gethomefolderpath getHomeFolderPath�i  �h   m   � � � f / L i b r a r y / P r e f e r e n c e s / c o . t h e a c h a r y a . M a r k e r D a t a . p l i s t�l  �k  �n  �m   � �g l 	 � ��f�e m   � � �		 � / p r i v a t e / v a r / f o l d e r s / y z / j v 3 j h f b d 0 z d 4 m z f d l d h y p s 8 8 0 0 0 0 g n / C / c o . t h e a c h a r y a . M a r k e r D a t a�f  �e  �g   � o      �d�d 0 folderpaths folderPaths��  ��   � 

 l     �c�b�a�c  �b  �a    l     �`�`   1 + Lists to store deleted and undeleted paths    � V   L i s t s   t o   s t o r e   d e l e t e d   a n d   u n d e l e t e d   p a t h s  l  � ��_�^ r   � � J   � ��]�]   o      �\�\ 0 deletedpaths deletedPaths�_  �^    l  � ��[�Z r   � � J   � ��Y�Y   o      �X�X  0 undeletedpaths undeletedPaths�[  �Z    l     �W�V�U�W  �V  �U    l  �2�T�S Z   �2 !�R"  =  � �#$# o   � ��Q�Q 0 
userchoice 
userChoice$ m   � �%% �&& * U n i n s t a l l   M a r k e r   D a t a! k   �'' ()( l  � ��P*+�P  * / ) Delete the folders with admin privileges   + �,, R   D e l e t e   t h e   f o l d e r s   w i t h   a d m i n   p r i v i l e g e s) -.- X   �</�O0/ k  711 232 r  454 b  676 m  88 �99  r m   - r f  7 n  :;: 1  
�N
�N 
strq; n  
<=< 1  
�M
�M 
psxp= o  �L�L 0 
folderpath 
folderPath5 o      �K�K 0 deletecommand deleteCommand3 >�J> Q  7?@A? k  )BB CDC I "�IEF
�I .sysoexecTEXT���     TEXTE o  �H�H 0 deletecommand deleteCommandF �GG�F
�G 
badmG m  �E
�E boovtrue�F  D H�DH r  #)IJI o  #$�C�C 0 
folderpath 
folderPathJ n      KLK  ;  '(L o  $'�B�B 0 deletedpaths deletedPaths�D  @ R      �AM�@
�A .ascrerr ****      � ****M o      �?�? 0 errmsg errMsg�@  A r  17NON o  12�>�> 0 
folderpath 
folderPathO n      PQP  ;  56Q o  25�=�=  0 undeletedpaths undeletedPaths�J  �O 0 
folderpath 
folderPath0 o   � ��<�< 0 folderpaths folderPaths. RSR l ==�;�:�9�;  �:  �9  S TUT l ==�8VW�8  V R L Create a text file on the desktop with lists of deleted and undeleted paths   W �XX �   C r e a t e   a   t e x t   f i l e   o n   t h e   d e s k t o p   w i t h   l i s t s   o f   d e l e t e d   a n d   u n d e l e t e d   p a t h sU YZY r  =J[\[ l =F]�7�6] b  =F^_^ I  =B�5�4�3�5 &0 gethomefolderpath getHomeFolderPath�4  �3  _ m  BE`` �aa  / D e s k t o p /�7  �6  \ o      �2�2 0 desktoppath desktopPathZ bcb r  K^ded I KZ�1fg
�1 .rdwropenshor       filef l KRh�0�/h b  KRiji o  KN�.�. 0 desktoppath desktopPathj m  NQkk �ll : M a r k e r - D a t a _ U n i n s t a l l _ L o g . t x t�0  �/  g �-m�,
�- 
permm m  UV�+
�+ boovtrue�,  e o      �*�* 0 logfile logFilec non l _jpqrp I _j�)st
�) .rdwrseofnull���     ****s o  _b�(�( 0 logfile logFilet �'u�&
�' 
set2u m  ef�%�%  �&  q %  Clearing the file if it exists   r �vv >   C l e a r i n g   t h e   f i l e   i f   i t   e x i s t so wxw I k|�$yz
�$ .rdwrwritnull���     ****y b  kr{|{ m  kn}} �~~ 4 D e l e t e d   F i l e s   a n d   F o l d e r s :| 1  nq�#
�# 
lnfdz �"�!
�" 
refn o  ux� �  0 logfile logFile�!  x ��� X  }����� I �����
� .rdwrwritnull���     ****� b  ����� o  ���� 0 itempath itemPath� 1  ���
� 
lnfd� ���
� 
refn� o  ���� 0 logfile logFile�  � 0 itempath itemPath� o  ���� 0 deletedpaths deletedPaths� ��� I �����
� .rdwrwritnull���     ****� 1  ���
� 
lnfd� ���
� 
refn� o  ���� 0 logfile logFile�  � ��� I �����
� .rdwrwritnull���     ****� b  ����� m  ���� ��� n U n d e l e t e d   F i l e s   a n d   F o l d e r s   ( M a n u a l   D e l e t i o n   R e q u i r e d ) :� 1  ���
� 
lnfd� ���
� 
refn� o  ���� 0 logfile logFile�  � ��� X  ������ I �����
� .rdwrwritnull���     ****� b  ����� o  ���� 0 itempath itemPath� 1  ���

�
 
lnfd� �	��
�	 
refn� o  ���� 0 logfile logFile�  � 0 itempath itemPath� o  ����  0 undeletedpaths undeletedPaths� ��� I �����
� .rdwrclosnull���     ****� o  ���� 0 logfile logFile�  � ��� l ����� �  �  �   � ��� I �����
�� .sysodlogaskr        TEXT� m  ���� ��� � M a r k e r   D a t a   w a s   s u c c e s s f u l l y   r e m o v e d   f r o m   y o u r   s y s t e m .   L o g   f i l e   c r e a t e d   o n   D e s k t o p .� ����
�� 
btns� J  ��� ���� m  ��� ���  O K��  � ����
�� 
dflt� m  �� ���  O K� �����
�� 
disp� l 	������ I 	�����
�� .sysorpthalis        TEXT� m  	�� ���  a p p l e t . i c n s��  ��  ��  ��  � ���� l ��������  ��  ��  ��  �R  " k  2�� ��� l ������  � &   User aborted the uninstallation   � ��� @   U s e r   a b o r t e d   t h e   u n i n s t a l l a t i o n� ���� I 2����
�� .sysodlogaskr        TEXT� m  �� ��� . U n i n s t a l l a t i o n   A b o r t e d .� ����
�� 
btns� J  "�� ���� m   �� ���  O K��  � ����
�� 
dflt� m  #&�� ���  O K� �����
�� 
disp� l '.������ I '.�����
�� .sysorpthalis        TEXT� m  '*�� ���  a p p l e t . i c n s��  ��  ��  ��  ��  �T  �S   ���� l     ��������  ��  ��  ��       �������  � ������ &0 gethomefolderpath getHomeFolderPath
�� .aevtoappnull  �   � ****� �� J���������� &0 gethomefolderpath getHomeFolderPath��  ��  �  � ������
�� afdrcusr
�� .earsffdralis        afdr
�� 
psxp�� 
�j �,E� �����������
�� .aevtoappnull  �   � ****� k    2��  ��  +��  9��  W��  ��� �� �� ����  ��  ��  � �������� 0 
folderpath 
folderPath�� 0 errmsg errMsg�� 0 itempath itemPath� K ��   �� $�� )������������ >���������� � ��� � � � � ��� � � � � � � ���������%������8������������`��k����������}�����������������
�� 
btns
�� 
dflt
�� 
disp
�� .sysorpthalis        TEXT�� 
�� .sysodlogaskr        TEXT
�� 
rslt
�� 
bhit�� 0 
userchoice 
userChoice�� 0 appname appName
�� 
capp
�� 
prun
�� .aevtquitnull��� ��� null
�� .sysodelanull��� ��� nmbr
�� .sysoexecTEXT���     TEXT�� &0 gethomefolderpath getHomeFolderPath�� 
�� 0 folderpaths folderPaths�� 0 deletedpaths deletedPaths��  0 undeletedpaths undeletedPaths
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
psxp
�� 
strq�� 0 deletecommand deleteCommand
�� 
badm�� 0 errmsg errMsg��  �� 0 desktoppath desktopPath
�� 
perm
�� .rdwropenshor       file�� 0 logfile logFile
�� 
set2
�� .rdwrseofnull���     ****
�� 
lnfd
�� 
refn
�� .rdwrwritnull���     ****
�� .rdwrclosnull���     ****��3����lv����j � 
O��,E�O�E�O*a �/a ,e  G*a �/ *j UOkj O*a �/a ,e a �%a %j Y a �%a %j Y a �%a %j Oa *j+ a %*j+ a %*j+ a %*j+ a  %*j+ a !%*j+ a "%*j+ a #%*j+ a $%a %a &vE` 'OjvE` (OjvE` )O�a * / O_ '[a +a ,l -kh  a .�a /,a 0,%E` 1O _ 1a 2el O�_ (6FW X 3 4�_ )6F[OY��O*j+ a 5%E` 6O_ 6a 7%a 8el 9E` :O_ :a ;jl <Oa =_ >%a ?_ :l @O )_ ([a +a ,l -kh �_ >%a ?_ :l @[OY��O_ >a ?_ :l @Oa A_ >%a ?_ :l @O )_ )[a +a ,l -kh �_ >%a ?_ :l @[OY��O_ :j BOa C�a Dkv�a E�a Fj � 
OPY a G�a Hkv�a I�a Jj � 
 ascr  ��ޭ